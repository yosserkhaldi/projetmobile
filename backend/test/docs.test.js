import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';

import { parse } from 'yaml';

import { startApi } from './helpers.js';

const spec = parse(
  readFileSync(new URL('../openapi.yaml', import.meta.url), 'utf8'),
);
const METHODS = ['get', 'post', 'put', 'patch', 'delete'];
const SAMPLE_ID = '11111111-1111-4111-8111-111111111111';

test('Swagger : servi sur /api/docs', async (t) => {
  const { base } = await startApi(t);
  const response = await fetch(`${base}/docs/`);
  assert.equal(response.status, 200);
  assert.match(await response.text(), /swagger-ui/i);
});

test('Swagger : chaque route documentée existe dans l API', async (t) => {
  const { base } = await startApi(t);
  for (const [path, item] of Object.entries(spec.paths)) {
    for (const method of METHODS.filter((m) => item[m])) {
      const url = base + path.replace(/\{[^}]+\}/g, SAMPLE_ID);
      const response = await fetch(url, { method: method.toUpperCase() });
      const body = await response.text();
      // Une route inconnue répond NOT_FOUND sans être passée par l'authentification.
      const unknown =
        response.status === 404 && body.includes('Ressource introuvable');
      assert.ok(!unknown, `${method.toUpperCase()} ${path} n'existe pas`);
    }
  }
});

test('Swagger : les références internes pointent vers un composant', () => {
  const text = JSON.stringify(spec);
  for (const [, section, name] of text.matchAll(
    /"#\/components\/(\w+)\/(\w+)"/g,
  )) {
    assert.ok(spec.components[section]?.[name], `${section}/${name} manquant`);
  }
});
