import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Coupon API', () => {
  it('GET /api/coupons returns 200', async () => {
    const res = await request(app).get('/api/coupons');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/coupons creates entity', async () => {
    const res = await request(app)
      .post('/api/coupons')
      .send({
      code: 'test',
      discountValue: 0.00,
      minOrderValue: 0.00,
      usesCount: 1,
      validFrom: '2024-01-01T00:00:00.000Z',
      validUntil: '2024-01-01T00:00:00.000Z',
      isActive: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/coupons/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/coupons/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/coupons/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/coupons/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/coupons/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/coupons/1');
    expect([204, 404]).toContain(res.status);
  });
});
