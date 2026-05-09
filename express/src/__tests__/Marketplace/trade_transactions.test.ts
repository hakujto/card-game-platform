import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('TradeTransaction API', () => {
  it('GET /api/trade_transactions returns 200', async () => {
    const res = await request(app).get('/api/trade_transactions');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/trade_transactions creates entity', async () => {
    const res = await request(app)
      .post('/api/trade_transactions')
      .send({
      finalPrice: 0.00,
      platformFee: 0.00
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/trade_transactions/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/trade_transactions/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_transactions/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/trade_transactions/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/trade_transactions/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/trade_transactions/1');
    expect([204, 404]).toContain(res.status);
  });
});
