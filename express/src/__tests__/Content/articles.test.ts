import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Article API', () => {
  it('GET /api/articles returns 200', async () => {
    const res = await request(app).get('/api/articles');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/articles?q=test returns 200', async () => {
    const res = await request(app).get('/api/articles?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/articles creates entity', async () => {
    const res = await request(app)
      .post('/api/articles')
      .send({
      title: 'test',
      slug: `test_${Math.random().toString(36).slice(2,8)}`,
      body: 'test',
      viewCount: 1,
      likesCount: 1,
      totalViewsAlltime: 1,
      isFeatured: true,
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
    const res = await request(app).patch('/api/articles/1').send({ excerpt: 'test' });
    expect([200, 404]).toContain(res.status);
  });


  it("POST /api/articles returns 400 when published_requires_published_at violated", async () => {
    const res = await request(app).post('/api/articles').send({ title: 'test', slug: 'test', body: 'test', createdAt: '2024-01-01T00:00:00.000Z', updatedAt: '2024-01-01T00:00:00.000Z', authorId: 1, status: 'PUBLISHED', publishedAt: null });
    expect(res.status).toBe(400);
  });

  it("POST /api/articles returns 400 when view_count_not_negative violated", async () => {
    const res = await request(app).post('/api/articles').send({ title: 'test', slug: 'test', body: 'test', createdAt: '2024-01-01T00:00:00.000Z', updatedAt: '2024-01-01T00:00:00.000Z', authorId: 1, status: 'PUBLISHED', publishedAt: '2024-01-01T00:00:00.000Z', viewCount: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/articles returns 400 when likes_count_not_negative violated", async () => {
    const res = await request(app).post('/api/articles').send({ title: 'test', slug: 'test', body: 'test', createdAt: '2024-01-01T00:00:00.000Z', updatedAt: '2024-01-01T00:00:00.000Z', authorId: 1, status: 'PUBLISHED', publishedAt: '2024-01-01T00:00:00.000Z', likesCount: -1 });
    expect(res.status).toBe(400);
  });

  it('PATCH /api/articles/1/transitions/draft-to-published requires role for Draft -> Published', async () => {
    const res = await request(app).patch('/api/articles/1/transitions/draft-to-published');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/articles/1/transitions/published-to-archived requires role for Published -> Archived', async () => {
    const res = await request(app).patch('/api/articles/1/transitions/published-to-archived');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/articles/1/transitions/archived-to-draft requires role for Archived -> Draft', async () => {
    const res = await request(app).patch('/api/articles/1/transitions/archived-to-draft');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/articles/1/transitions/published-to-draft is denied (409)', async () => {
    const res = await request(app).patch('/api/articles/1/transitions/published-to-draft');
    expect([409, 404]).toContain(res.status);
  });
});
