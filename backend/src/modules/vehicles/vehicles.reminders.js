import cron from 'node-cron';

import { notifier } from '../../lib/notifier.js';
import { prisma } from '../../lib/prisma.js';

// Module 2 : rappels d'échéance (cahier des charges : 30, 7 et 1 jours avant).
export const REMINDER_DAYS = [30, 7, 1];

const DAY_MS = 86_400_000;
const formatDate = (date) => date.toISOString().slice(0, 10).split('-').reverse().join('/');

/** Minuit UTC du jour donné : les échéances sont des dates sans heure. */
function dayOf(date) {
  return new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
}

function message(vehicle, kind, days, date) {
  const what = kind === 'insurance' ? 'Votre assurance' : 'Votre visite technique';
  const when = days === 1 ? 'demain' : `dans ${days} jours`;
  return `Mon Constat : ${what} pour ${vehicle.brand} ${vehicle.model} (${vehicle.plate}) expire ${when}, le ${formatDate(date)}.`;
}

/**
 * Envoie les rappels du jour : WhatsApp et notification dans l'application.
 * Une échéance n'est rappelée qu'aux jours exacts (J-30, J-7, J-1) : lancé
 * une fois par jour, chaque rappel part une seule fois. Renvoie le nombre de
 * rappels envoyés.
 */
export async function sendExpiryReminders(now = new Date()) {
  const today = dayOf(now);
  let sent = 0;
  for (const days of REMINDER_DAYS) {
    const target = new Date(today.getTime() + days * DAY_MS);
    const vehicles = await prisma.vehicle.findMany({
      where: {
        archived: false,
        OR: [{ insuranceExpiry: target }, { technicalExpiry: target }],
      },
      include: { user: { select: { id: true, phone: true, deletedAt: true } } },
    });
    for (const vehicle of vehicles) {
      if (vehicle.user.deletedAt) continue;
      const kinds = [
        vehicle.insuranceExpiry?.getTime() === target.getTime() && 'insurance',
        vehicle.technicalExpiry?.getTime() === target.getTime() && 'technical',
      ].filter(Boolean);
      for (const kind of kinds) {
        const body = message(vehicle, kind, days, target);
        await prisma.claimNotification.create({
          data: { audience: 'driver', recipientId: vehicle.user.id, body },
        });
        await notifier.sendToPhone(vehicle.user.phone, body);
        sent += 1;
      }
    }
  }
  return sent;
}

/** Tous les jours à 8 h (heure de Tunis). */
export function scheduleExpiryReminders() {
  return cron.schedule(
    '0 8 * * *',
    () => {
      sendExpiryReminders().catch((err) =>
        console.error('Rappels d’échéance impossibles', err),
      );
    },
    { timezone: 'Africa/Tunis' },
  );
}
