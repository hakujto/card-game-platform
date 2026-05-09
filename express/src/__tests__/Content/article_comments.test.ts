import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('ArticleComment API', () => {
  it('GET /api/article_comments returns 200', async () => {
    const res = await request(app).get('/api/article_comments');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/article_comments creates entity', async () => {
    const res = await request(app)
      .post('/api/article_comments')
      .send({
      body: 'test',
      isHidden: true,
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/article_comments/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/article_comments/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/article_comments/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/article_comments/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/article_comments/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/article_comments/1');
    expect([204, 404]).toContain(res.status);
  });
});
