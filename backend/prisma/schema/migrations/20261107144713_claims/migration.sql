-- CreateTable
CREATE TABLE "Claim" (
    "id" TEXT NOT NULL,
    "constatId" TEXT,
    "companyId" TEXT,
    "driverId" TEXT NOT NULL,
    "agentId" TEXT,
    "agentName" TEXT,
    "type" TEXT NOT NULL,
    "place" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "severity" TEXT NOT NULL,
    "observations" TEXT NOT NULL DEFAULT '',
    "circumstances" TEXT[],
    "impactZones" TEXT[],
    "expertName" TEXT,
    "expertAppointment" TIMESTAMP(3),
    "responsibility" INTEGER,
    "indemnity" DOUBLE PRECISION,
    "decisionReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Claim_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ClaimEvent" (
    "id" SERIAL NOT NULL,
    "claimId" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ClaimEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ClaimDocument" (
    "id" TEXT NOT NULL,
    "claimId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "kind" TEXT NOT NULL DEFAULT 'Pièce',
    "storedName" TEXT,
    "requestId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ClaimDocument_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DocumentRequest" (
    "id" TEXT NOT NULL,
    "claimId" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "note" TEXT NOT NULL DEFAULT '',
    "documentId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DocumentRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ClaimNotification" (
    "id" TEXT NOT NULL,
    "claimId" TEXT,
    "audience" TEXT NOT NULL,
    "recipientId" TEXT,
    "body" TEXT NOT NULL,
    "read" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ClaimNotification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ChatMessage" (
    "id" TEXT NOT NULL,
    "claimId" TEXT NOT NULL,
    "author" TEXT NOT NULL,
    "senderRole" TEXT NOT NULL,
    "body" TEXT NOT NULL DEFAULT '',
    "attachmentName" TEXT,
    "attachmentStored" TEXT,
    "read" BOOLEAN NOT NULL DEFAULT false,
    "sentAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ChatMessage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProcessedRequest" (
    "key" TEXT NOT NULL,
    "status" INTEGER NOT NULL,
    "body" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ProcessedRequest_pkey" PRIMARY KEY ("key")
);

-- CreateIndex
CREATE INDEX "ClaimEvent_claimId_idx" ON "ClaimEvent"("claimId");

-- CreateIndex
CREATE INDEX "ClaimDocument_claimId_idx" ON "ClaimDocument"("claimId");

-- CreateIndex
CREATE INDEX "DocumentRequest_claimId_idx" ON "DocumentRequest"("claimId");

-- CreateIndex
CREATE INDEX "ClaimNotification_audience_recipientId_idx" ON "ClaimNotification"("audience", "recipientId");

-- CreateIndex
CREATE INDEX "ChatMessage_claimId_idx" ON "ChatMessage"("claimId");

-- AddForeignKey
ALTER TABLE "ClaimEvent" ADD CONSTRAINT "ClaimEvent_claimId_fkey" FOREIGN KEY ("claimId") REFERENCES "Claim"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ClaimDocument" ADD CONSTRAINT "ClaimDocument_claimId_fkey" FOREIGN KEY ("claimId") REFERENCES "Claim"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DocumentRequest" ADD CONSTRAINT "DocumentRequest_claimId_fkey" FOREIGN KEY ("claimId") REFERENCES "Claim"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChatMessage" ADD CONSTRAINT "ChatMessage_claimId_fkey" FOREIGN KEY ("claimId") REFERENCES "Claim"("id") ON DELETE CASCADE ON UPDATE CASCADE;
