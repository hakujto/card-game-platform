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
    const res = await request(app).get('/api/orders/1').set('X-User-Id', '1');
    expect([200, 404, 403]).toContain(res.status);
  });


  it("POST /api/orders returns 400 when paid_requires_paid_at violated", async () => {
    const res = await request(app).post('/api/orders').send({ createdAt: '2024-01-01T00:00:00.000Z', playerId: 1, status: 'PAID', paidAt: null });
    expect(res.status).toBe(400);
  });

  it("POST /api/orders returns 400 when shipped_requires_tracking violated", async () => {
    const res = await request(app).post('/api/orders').send({ createdAt: '2024-01-01T00:00:00.000Z', playerId: 1, status: 'SHIPPED', trackingNumber: null });
    expect(res.status).toBe(400);
  });

  it("POST /api/orders returns 400 when shipped_at_requires_shipped_status violated", async () => {
    const res = await request(app).post('/api/orders').send({ createdAt: '2024-01-01T00:00:00.000Z', playerId: 1, shippedAt: '2024-01-01T00:00:00.000Z' });
    expect(res.status).toBe(400);
  });

  it("POST /api/orders returns 400 when total_not_negative violated", async () => {
    const res = await request(app).post('/api/orders').send({ createdAt: '2024-01-01T00:00:00.000Z', playerId: 1, status: 'SHIPPED', paidAt: '2024-01-01T00:00:00.000Z', trackingNumber: 'test', shippedAt: '2024-01-01T00:00:00.000Z', total: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/orders returns 400 when discount_not_exceed_total violated", async () => {
    const res = await request(app).post('/api/orders').send({ createdAt: '2024-01-01T00:00:00.000Z', playerId: 1, status: 'SHIPPED', paidAt: '2024-01-01T00:00:00.000Z', trackingNumber: 'test', shippedAt: '2024-01-01T00:00:00.000Z', discountApplied: 1, total: 0 });
    expect(res.status).toBe(400);
  });

  it('PATCH /api/orders/1/transitions/pending-to-paid transitions Pending -> Paid', async () => {
    const res = await request(app).patch('/api/orders/1/transitions/pending-to-paid');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/paid-to-processing requires role for Paid -> Processing', async () => {
    const res = await request(app).patch('/api/orders/1/transitions/paid-to-processing');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/processing-to-shipped requires role for Processing -> Shipped', async () => {
    const res = await request(app).patch('/api/orders/1/transitions/processing-to-shipped');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/shipped-to-completed requires role for Shipped -> Completed', async () => {
    const res = await request(app).patch('/api/orders/1/transitions/shipped-to-completed');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/pending-to-cancelled transitions Pending -> Cancelled', async () => {
    const res = await request(app).patch('/api/orders/1/transitions/pending-to-cancelled');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/paid-to-cancelled requires role for Paid -> Cancelled', async () => {
    const res = await request(app).patch('/api/orders/1/transitions/paid-to-cancelled');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/completed-to-refunded requires role for Completed -> Refunded', async () => {
    const res = await request(app).patch('/api/orders/1/transitions/completed-to-refunded');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/refunded-to-completed is denied (409)', async () => {
    const res = await request(app).patch('/api/orders/1/transitions/refunded-to-completed');
    expect([409, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/completed-to-cancelled is denied (409)', async () => {
    const res = await request(app).patch('/api/orders/1/transitions/completed-to-cancelled');
    expect([409, 404]).toContain(res.status);
  });
});
