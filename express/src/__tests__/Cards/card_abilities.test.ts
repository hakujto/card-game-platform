import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('CardAbility API', () => {
  it('GET /api/card_abilities returns 200', async () => {
    const res = await request(app).get('/api/card_abilities');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/card_abilities creates entity', async () => {
    const res = await request(app)
      .post('/api/card_abilities')
      .send({
      abilityText: 'test'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/card_abilities/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/card_abilities/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/card_abilities/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/card_abilities/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/card_abilities/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/card_abilities/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/card_abilities returns 400 when keyword_ability_requires_keyword violated", async () => {
    const res = await request(app).post('/api/card_abilities').send({ abilityText: 'test', cardId: 1, abilityType: 'KEYWORD', keyword: null });
    expect(res.status).toBe(400);
  });
});
