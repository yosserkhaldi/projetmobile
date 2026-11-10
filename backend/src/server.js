import { createApp } from './app.js';
import { assertAuthConfig } from './lib/tokens.js';
import { attachClaimsSocket } from './modules/claims/claims.socket.js';
import { scheduleExpiryReminders } from './modules/vehicles/vehicles.reminders.js';

assertAuthConfig();

const port = Number(process.env.PORT ?? 3000);

const server = createApp().listen(port, () => {
  console.log(`API démarrée sur le port ${port}`);
});

attachClaimsSocket(server);

// Rappels d'échéance des contrats et visites techniques (module 2).
scheduleExpiryReminders();
