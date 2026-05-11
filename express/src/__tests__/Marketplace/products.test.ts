import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Product API', () => {
  it('GET /api/products returns 200', async () => {
    const res = await request(app).get('/api/products');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/products creates entity', async () => {
    const res = await request(app)
      .post('/api/products')
      .send({
      name: 'test',
      price: 0.00,
      stock: 1,
      active: true,
      discountPercent: 1,
      featured: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/products/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/products/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/products/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/products/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/products/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/products/1');
    expect([204, 404]).toContain(res.status);
  });
});
