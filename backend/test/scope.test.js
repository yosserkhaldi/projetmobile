import assert from 'node:assert/strict';
import { after, before, beforeEach, test } from 'node:test';

import { migrate, prisma, resetDatabase } from './helpers.js';

const { companyScope, assertCompanyExists } = await import(
  '../src/middleware/auth.js'
);

before(migrate);
beforeEach(resetDatabase);
after(() => prisma.$disconnect());

test('companyScope : l administrateur voit tout', () => {
  assert.deepEqual(companyScope({ user: { role: 'ADMIN' } }), {});
});

test('companyScope : l agent ne voit que sa compagnie', () => {
  assert.deepEqual(
    companyScope({ user: { role: 'AGENT', companyId: 'c1' } }),
    { companyId: 'c1' },
  );
  assert.deepEqual(
    companyScope({ user: { role: 'AGENT', companyId: 'c1' } }, 'insurerId'),
    { insurerId: 'c1' },
  );
});

test('companyScope : agent sans compagnie et conducteur refusés', () => {
  assert.throws(
    () => companyScope({ user: { role: 'AGENT', companyId: null } }),
    (err) => err.code === 'AGENT_WITHOUT_COMPANY',
  );
  assert.throws(
    () => companyScope({ user: { role: 'DRIVER' } }),
    (err) => err.status === 403,
  );
});

test('assertCompanyExists : compagnie connue ou erreur claire', async () => {
  const company = await prisma.company.create({ data: { name: 'STAR' } });
  assert.equal((await assertCompanyExists(company.id)).name, 'STAR');
  await assert.rejects(
    assertCompanyExists('11111111-1111-4111-8111-111111111111'),
    (err) => err.code === 'COMPANY_NOT_FOUND',
  );
  await assert.rejects(assertCompanyExists(undefined), (err) => err.status === 400);
});
