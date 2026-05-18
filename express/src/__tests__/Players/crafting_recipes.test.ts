import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('CraftingRecipe API', () => {
  it('GET /api/crafting_recipes returns 200', async () => {
    const res = await request(app).get('/api/crafting_recipes');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/crafting_recipes creates entity', async () => {
    const res = await request(app)
      .post('/api/crafting_recipes')
      .send({
      dustCost: 1,
      isAvailable: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/crafting_recipes/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/crafting_recipes/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/crafting_recipes/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/crafting_recipes/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/crafting_recipes/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/crafting_recipes/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/crafting_recipes returns 400 when dust_cost_positive violated", async () => {
    const res = await request(app).post('/api/crafting_recipes').send({ resultCardId: 1, dustCost: 0 });
    expect(res.status).toBe(400);
  });
});
