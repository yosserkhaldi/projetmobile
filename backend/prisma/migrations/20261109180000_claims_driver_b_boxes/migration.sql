-- Module 5 : cases cochées par le conducteur B (module 4), pour la proposition.
ALTER TABLE "Claim" ADD COLUMN "circumstancesB" TEXT[] DEFAULT ARRAY[]::TEXT[];
