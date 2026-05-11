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
});
