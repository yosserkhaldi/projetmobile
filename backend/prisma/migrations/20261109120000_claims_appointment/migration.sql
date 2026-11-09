-- Module 5 : rendez-vous d'expertise négocié entre l'agent et le conducteur.
ALTER TABLE "Claim" ADD COLUMN "expertPhone" TEXT;
ALTER TABLE "Claim" ADD COLUMN "expertPlace" TEXT;
ALTER TABLE "Claim" ADD COLUMN "expertKind" TEXT;
ALTER TABLE "Claim" ADD COLUMN "appointmentState" TEXT;
ALTER TABLE "Claim" ADD COLUMN "appointmentBy" TEXT;
ALTER TABLE "Claim" ADD COLUMN "appointmentNote" TEXT;
