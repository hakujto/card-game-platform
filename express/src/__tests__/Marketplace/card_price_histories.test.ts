import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('CardPriceHistory API', () => {
  it('GET /api/card_price_histories returns 200', async () => {
    const res = await request(app).get('/api/card_price_histories');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/card_price_histories/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/card_price_histories/1');
    expect([200, 404]).toContain(res.status);
  });

});
