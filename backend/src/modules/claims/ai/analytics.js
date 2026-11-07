import { Status } from '../claims.workflow.js';
import { model } from './insights.js';
import { serviceLevel } from './rules.js';

const average = (values) =>
  values.length === 0
    ? null
    : values.reduce((sum, value) => sum + value, 0) / values.length;

const countBy = (claims, key) =>
  claims.reduce((counts, claim) => {
    counts[claim[key]] = (counts[claim[key]] ?? 0) + 1;
    return counts;
  }, {});

const durationDays = (claim) =>
  (new Date(claim.events.at(-1)?.createdAt ?? claim.updatedAt) -
    new Date(claim.createdAt)) /
  86_400_000;

export function analytics(claims, aiCalls = [], now = new Date()) {
  const closed = claims.filter((claim) => claim.status === Status.closed);
  const done = claims.filter((claim) =>
    [Status.closed, Status.rejected].includes(claim.status),
  );
  const compared = closed.filter(
    (claim) => claim.aiProposal && claim.responsibility != null,
  );
  const priced = compared.filter((claim) => claim.indemnity != null);
  const agreement = average(
    compared.map((claim) =>
      claim.aiProposal.responsibility === claim.responsibility ? 1 : 0,
    ),
  );
  const estimateError = average(
    priced.map((claim) => Math.abs(claim.aiProposal.estimate.mid - claim.indemnity)),
  );
  return {
    total: claims.length,
    byStatus: countBy(claims, 'status'),
    bySeverity: countBy(claims, 'severity'),
    overdue: claims.filter((claim) => serviceLevel(claim, now)?.overdueDays > 0).length,
    averageDays: average(done.map(durationDays)),
    totalIndemnity: closed.reduce((sum, claim) => sum + (claim.indemnity ?? 0), 0),
    ai: {
      decisionsCompared: compared.length,
      agreement,
      estimateErrorTnd: estimateError,
      claudeCalls: aiCalls.filter((call) => call.source === 'claude').length,
      failedCalls: aiCalls.filter((call) => !call.ok).length,
    },
    model: {
      version: model.version,
      trainedOn: model.trainedOn,
      metrics: model.metrics,
    },
  };
}
