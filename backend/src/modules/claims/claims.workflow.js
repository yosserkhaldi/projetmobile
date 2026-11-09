// Cycle de vie d'un dossier, identique à ClaimStatus côté Flutter.
export const Status = Object.freeze({
  draft: 'Brouillon',
  declared: 'Déclaré',
  signed: 'Constat signé',
  transmitted: 'Transmis',
  inReview: 'En instruction',
  documentRequested: 'Pièce demandée',
  expertise: 'Expertise',
  closed: 'Clôturé',
  rejected: 'Rejeté',
});

const next = {
  [Status.draft]: [Status.declared],
  [Status.declared]: [Status.signed],
  [Status.signed]: [Status.transmitted],
  [Status.transmitted]: [Status.inReview],
  [Status.inReview]: [
    Status.documentRequested,
    Status.expertise,
    Status.closed,
    Status.rejected,
  ],
  [Status.documentRequested]: [Status.inReview, Status.rejected],
  [Status.expertise]: [Status.closed, Status.rejected],
};

export const canMove = (from, to) => (next[from] ?? []).includes(to);
