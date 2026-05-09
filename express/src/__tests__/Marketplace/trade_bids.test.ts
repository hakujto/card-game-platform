import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('TradeBid API', () => {
  it('GET /api/trade_bids returns 200', async () => {
    const res = await request(app).get('/api/trade_bids');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/trade_bids creates entity', async () => {
    const res = await request(app)
      .post('/api/trade_bids')
      .send({
      amount: 0.00,
      placedAt: '2024-01-01T00:00:00.000Z',
      isWinning: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/trade_bids/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/trade_bids/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_bids/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/trade_bids/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/trade_bids/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/trade_bids/1');
    expect([204, 404]).toContain(res.status);
  });
});
