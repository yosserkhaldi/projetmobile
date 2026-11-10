-- CreateEnum
CREATE TYPE "LicenseStatus" AS ENUM ('VERIFIED', 'TO_REVIEW', 'REJECTED');

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "licenseChecks" JSONB,
ADD COLUMN     "licenseRejectionReason" TEXT,
ADD COLUMN     "licenseReviewedAt" TIMESTAMP(3),
ADD COLUMN     "licenseStatus" "LicenseStatus";
