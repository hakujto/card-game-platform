import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Article API', () => {
  it('GET /api/articles returns 200', async () => {
    const res = await request(app).get('/api/articles');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/articles creates entity', async () => {
    const res = await request(app)
      .post('/api/articles')
      .send({
      title: 'test',
      slug: 'test',
      body: 'test',
      viewCount: 1,
      createdAt: '2024-01-01T00:00:00.000Z',
      updatedAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/articles/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/articles/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/articles/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/articles/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/articles/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/articles/1');
    expect([204, 404]).toContain(res.status);
  });
});
