-- CreateEnum
CREATE TYPE "IdentityDocument" AS ENUM ('CIN', 'LICENSE', 'PASSPORT');

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "identityAutoVerified" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "identityDocument" "IdentityDocument" NOT NULL DEFAULT 'CIN',
ADD COLUMN     "identityFaceMatch" DOUBLE PRECISION,
ADD COLUMN     "identityLivenessAt" TIMESTAMP(3),
ADD COLUMN     "identitySelfieFile" TEXT;
