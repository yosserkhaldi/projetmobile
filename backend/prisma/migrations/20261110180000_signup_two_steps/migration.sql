-- Inscription en deux temps : le nom et le téléphone sont demandés après
-- l'e-mail et le mot de passe, dans l'accueil de l'application.
ALTER TABLE "User" ALTER COLUMN "firstName" SET DEFAULT '',
ALTER COLUMN "lastName" SET DEFAULT '',
ALTER COLUMN "phone" DROP NOT NULL;
