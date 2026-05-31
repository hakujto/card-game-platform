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

  it('GET /api/trade_transactions/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/trade_transactions/1');
    expect([200, 404]).toContain(res.status);
  });

});
