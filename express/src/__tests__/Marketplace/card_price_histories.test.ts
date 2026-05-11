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

  it('POST /api/card_price_histories creates entity', async () => {
    const res = await request(app)
      .post('/api/card_price_histories')
      .send({
      priceDate: '2024-01-01',
      avgPrice: 0.00,
      minPrice: 0.00,
      maxPrice: 0.00,
      volume: 1,
      foil: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/card_price_histories/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/card_price_histories/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/card_price_histories/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/card_price_histories/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/card_price_histories/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/card_price_histories/1');
    expect([204, 404]).toContain(res.status);
  });
});
