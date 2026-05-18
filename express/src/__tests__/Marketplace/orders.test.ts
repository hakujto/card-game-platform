import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Order API', () => {
  it('GET /api/orders returns 200', async () => {
    const res = await request(app).get('/api/orders');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/orders creates entity', async () => {
    const res = await request(app)
      .post('/api/orders')
      .send({
      total: 0.00,
      discountApplied: 0.00,
      currency: 'test',
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/orders/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/orders/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/orders/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/orders/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/orders/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/orders returns 400 when paid_requires_paid_at violated", async () => {
    const res = await request(app).post('/api/orders').send({ createdAt: '2024-01-01T00:00:00.000Z', playerId: 1, status: 'PAID', paidAt: null });
    expect(res.status).toBe(400);
  });

  it("POST /api/orders returns 400 when shipped_requires_tracking violated", async () => {
    const res = await request(app).post('/api/orders').send({ createdAt: '2024-01-01T00:00:00.000Z', playerId: 1, status: 'SHIPPED', trackingNumber: null });
    expect(res.status).toBe(400);
  });

  it("POST /api/orders returns 400 when total_not_negative violated", async () => {
    const res = await request(app).post('/api/orders').send({ createdAt: '2024-01-01T00:00:00.000Z', playerId: 1, status: 'SHIPPED', paidAt: '2024-01-01T00:00:00.000Z', trackingNumber: 'test', total: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/orders returns 400 when discount_not_exceed_total violated", async () => {
    const res = await request(app).post('/api/orders').send({ createdAt: '2024-01-01T00:00:00.000Z', playerId: 1, status: 'SHIPPED', paidAt: '2024-01-01T00:00:00.000Z', trackingNumber: 'test', discountApplied: 1 });
    expect(res.status).toBe(400);
  });
});
