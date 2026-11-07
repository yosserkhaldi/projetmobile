-- AlterTable
ALTER TABLE "User" ADD COLUMN     "licensePhotoFile" TEXT,
ADD COLUMN     "photoFile" TEXT;

-- CreateTable
CREATE TABLE "DeviceKey" (
    "id" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "userId" UUID NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "revokedAt" TIMESTAMP(3),
    "lastUsedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DeviceKey_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "DeviceKey_tokenHash_key" ON "DeviceKey"("tokenHash");

-- CreateIndex
CREATE INDEX "DeviceKey_userId_idx" ON "DeviceKey"("userId");

-- AddForeignKey
ALTER TABLE "DeviceKey" ADD CONSTRAINT "DeviceKey_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
