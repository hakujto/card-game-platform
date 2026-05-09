import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('CraftingIngredient API', () => {
  it('GET /api/crafting_ingredients returns 200', async () => {
    const res = await request(app).get('/api/crafting_ingredients');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/crafting_ingredients creates entity', async () => {
    const res = await request(app)
      .post('/api/crafting_ingredients')
      .send({
      quantity: 1
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/crafting_ingredients/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/crafting_ingredients/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/crafting_ingredients/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/crafting_ingredients/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/crafting_ingredients/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/crafting_ingredients/1');
    expect([204, 404]).toContain(res.status);
  });
});
