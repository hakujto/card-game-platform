import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

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
      finalPrice: 1,
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

  it("POST /api/trade_transactions returns 400 when fee_not_exceed_price violated", async () => {
    const res = await request(app).post('/api/trade_transactions').send({ finalPrice: 1, listingId: 1, buyerId: 1, sellerId: 1, status: 'COMPLETED', completedAt: '2024-01-01T00:00:00.000Z', platformFee: 1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/trade_transactions returns 400 when fee_not_negative violated", async () => {
    const res = await request(app).post('/api/trade_transactions').send({ finalPrice: 1, listingId: 1, buyerId: 1, sellerId: 1, status: 'COMPLETED', completedAt: '2024-01-01T00:00:00.000Z', platformFee: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/trade_transactions returns 400 when final_price_positive violated", async () => {
    const res = await request(app).post('/api/trade_transactions').send({ platformFee: 0.00, listingId: 1, buyerId: 1, sellerId: 1, status: 'COMPLETED', completedAt: '2024-01-01T00:00:00.000Z', finalPrice: 0 });
    expect(res.status).toBe(400);
  });

  it("POST /api/trade_transactions returns 400 when completed_requires_completed_at violated", async () => {
    const res = await request(app).post('/api/trade_transactions').send({ finalPrice: 1, platformFee: 0.00, listingId: 1, buyerId: 1, sellerId: 1, status: 'COMPLETED', completedAt: null });
    expect(res.status).toBe(400);
  });
});
