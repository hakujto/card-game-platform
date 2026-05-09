import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('OrderItem API', () => {
  it('GET /api/order_items returns 200', async () => {
    const res = await request(app).get('/api/order_items');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/order_items creates entity', async () => {
    const res = await request(app)
      .post('/api/order_items')
      .send({
      quantity: 1,
      priceAtPurchase: 0.00,
      foil: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/order_items/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/order_items/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/order_items/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/order_items/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/order_items/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/order_items/1');
    expect([204, 404]).toContain(res.status);
  });
});
