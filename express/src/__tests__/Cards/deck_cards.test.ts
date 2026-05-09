import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('DeckCard API', () => {
  it('GET /api/deck_cards returns 200', async () => {
    const res = await request(app).get('/api/deck_cards');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/deck_cards creates entity', async () => {
    const res = await request(app)
      .post('/api/deck_cards')
      .send({
      quantity: 1,
      isCommander: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/deck_cards/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/deck_cards/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/deck_cards/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/deck_cards/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/deck_cards/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/deck_cards/1');
    expect([204, 404]).toContain(res.status);
  });
});
