-- Permis enregistrés avant les contrôles croisés : jamais contrôlés, un
-- administrateur les vérifie.
UPDATE "User"
SET "licenseStatus" = 'TO_REVIEW'
WHERE "licenseStatus" IS NULL
  AND ("licensePhotoFile" IS NOT NULL OR "licenseNumber" IS NOT NULL);
