-- AlterTable
ALTER TABLE "User" ADD COLUMN     "identityBlocked" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "identityRefusals" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "identityRetryAt" TIMESTAMP(3);

-- CreateTable
CREATE TABLE "IdentityAttempt" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "documentType" "IdentityDocument" NOT NULL,
    "number" TEXT NOT NULL,
    "faceMatch" DOUBLE PRECISION,
    "checks" JSONB,
    "outcome" TEXT NOT NULL,
    "reason" TEXT,
    "severe" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "decidedAt" TIMESTAMP(3),

    CONSTRAINT "IdentityAttempt_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "IdentityAttempt_userId_createdAt_idx" ON "IdentityAttempt"("userId", "createdAt");

-- AddForeignKey
ALTER TABLE "IdentityAttempt" ADD CONSTRAINT "IdentityAttempt_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
