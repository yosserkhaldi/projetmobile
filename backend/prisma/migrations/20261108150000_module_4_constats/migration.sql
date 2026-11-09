-- CreateEnum
CREATE TYPE "ConstatStatus" AS ENUM ('SIGNED', 'TRANSMITTED', 'ARCHIVED');

-- CreateTable
CREATE TABLE "Constat" (
    "id" UUID NOT NULL,
    "accidentId" UUID,
    "userId" UUID NOT NULL,
    "status" "ConstatStatus" NOT NULL DEFAULT 'SIGNED',
    "sha256Hash" TEXT NOT NULL,
    "pdfFile" TEXT NOT NULL,
    "driverAName" TEXT NOT NULL,
    "driverAPlate" TEXT NOT NULL,
    "driverAInsurer" TEXT NOT NULL,
    "driverAPolicy" TEXT,
    "companyAId" UUID,
    "driverBName" TEXT NOT NULL,
    "driverBEmail" TEXT,
    "driverBPhone" TEXT,
    "driverBPlate" TEXT NOT NULL,
    "driverBInsurer" TEXT NOT NULL,
    "driverBPolicy" TEXT,
    "companyBId" UUID,
    "place" TEXT NOT NULL,
    "occurredAt" TIMESTAMP(3) NOT NULL,
    "circumstancesA" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "circumstancesB" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "impactZones" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "observations" TEXT,
    "sketchData" JSONB,
    "driverASignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "driverBSignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Constat_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Constat_accidentId_key" ON "Constat"("accidentId");

-- CreateIndex
CREATE UNIQUE INDEX "Constat_sha256Hash_key" ON "Constat"("sha256Hash");

-- CreateIndex
CREATE INDEX "Constat_userId_idx" ON "Constat"("userId");

-- CreateIndex
CREATE INDEX "Constat_companyAId_idx" ON "Constat"("companyAId");

-- CreateIndex
CREATE INDEX "Constat_companyBId_idx" ON "Constat"("companyBId");

-- CreateIndex
CREATE INDEX "Constat_sha256Hash_idx" ON "Constat"("sha256Hash");

-- AddForeignKey
ALTER TABLE "Constat" ADD CONSTRAINT "Constat_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Constat" ADD CONSTRAINT "Constat_accidentId_fkey" FOREIGN KEY ("accidentId") REFERENCES "Accident"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Constat" ADD CONSTRAINT "Constat_companyAId_fkey" FOREIGN KEY ("companyAId") REFERENCES "Company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Constat" ADD CONSTRAINT "Constat_companyBId_fkey" FOREIGN KEY ("companyBId") REFERENCES "Company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

