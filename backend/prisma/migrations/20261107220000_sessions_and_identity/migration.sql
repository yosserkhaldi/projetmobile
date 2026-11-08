-- Les anciennes sessions n ont pas d appareil associé : chacun se reconnecte une fois.
DELETE FROM "RefreshToken";

-- CreateEnum
CREATE TYPE "IdentityStatus" AS ENUM ('UNVERIFIED', 'PENDING', 'VERIFIED', 'REJECTED');

-- AlterTable
ALTER TABLE "RefreshToken" ADD COLUMN     "sessionId" UUID NOT NULL;

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "cinBackFile" TEXT,
ADD COLUMN     "cinFrontFile" TEXT,
ADD COLUMN     "cinNumber" TEXT,
ADD COLUMN     "identityRejectionReason" TEXT,
ADD COLUMN     "identityReviewedAt" TIMESTAMP(3),
ADD COLUMN     "identityReviewerId" UUID,
ADD COLUMN     "identityStatus" "IdentityStatus" NOT NULL DEFAULT 'UNVERIFIED',
ADD COLUMN     "identitySubmittedAt" TIMESTAMP(3);

-- CreateTable
CREATE TABLE "Session" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "deviceId" TEXT,
    "deviceName" TEXT,
    "ip" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LoginEvent" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "success" BOOLEAN NOT NULL,
    "method" TEXT NOT NULL,
    "reason" TEXT,
    "deviceName" TEXT,
    "ip" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LoginEvent_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Session_userId_idx" ON "Session"("userId");

-- CreateIndex
CREATE INDEX "LoginEvent_userId_createdAt_idx" ON "LoginEvent"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "RefreshToken_sessionId_idx" ON "RefreshToken"("sessionId");

-- CreateIndex
CREATE UNIQUE INDEX "User_cinNumber_key" ON "User"("cinNumber");

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RefreshToken" ADD CONSTRAINT "RefreshToken_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LoginEvent" ADD CONSTRAINT "LoginEvent_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

