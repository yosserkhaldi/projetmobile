-- AlterTable
ALTER TABLE "Claim" ADD COLUMN     "aiProposal" JSONB;

-- AlterTable
ALTER TABLE "ClaimDocument" ADD COLUMN     "analysis" JSONB;

-- CreateTable
CREATE TABLE "ClaimAiNote" (
    "claimId" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "hash" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ClaimAiNote_pkey" PRIMARY KEY ("claimId","kind")
);

-- CreateTable
CREATE TABLE "AiCall" (
    "id" SERIAL NOT NULL,
    "claimId" TEXT,
    "feature" TEXT NOT NULL,
    "actorRole" TEXT NOT NULL,
    "source" TEXT NOT NULL,
    "model" TEXT,
    "ok" BOOLEAN NOT NULL,
    "error" TEXT,
    "inputTokens" INTEGER,
    "outputTokens" INTEGER,
    "ms" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AiCall_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "AiCall_claimId_idx" ON "AiCall"("claimId");
