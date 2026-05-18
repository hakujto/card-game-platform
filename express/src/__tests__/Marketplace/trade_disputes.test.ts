import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('TradeDispute API', () => {
  it('GET /api/trade_disputes returns 200', async () => {
    const res = await request(app).get('/api/trade_disputes');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/trade_disputes creates entity', async () => {
    const res = await request(app)
      .post('/api/trade_disputes')
      .send({
      description: 'test',
      openedAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/trade_disputes/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/trade_disputes/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_disputes/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/trade_disputes/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/trade_disputes/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/trade_disputes/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/trade_disputes returns 400 when resolved_at_requires_terminal_status violated", async () => {
    const res = await request(app).post('/api/trade_disputes').send({ reason: 'ITEMNOTRECEIVED', description: 'test', openedAt: '2024-01-01T00:00:00.000Z', transactionId: 1, openedById: 1, resolvedAt: '2024-01-01T00:00:00.000Z' });
    expect(res.status).toBe(400);
  });
});
