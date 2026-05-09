import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Friendship API', () => {
  it('GET /api/friendships returns 200', async () => {
    const res = await request(app).get('/api/friendships');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/friendships creates entity', async () => {
    const res = await request(app)
      .post('/api/friendships')
      .send({
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/friendships/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/friendships/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/friendships/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/friendships/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/friendships/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/friendships/1');
    expect([204, 404]).toContain(res.status);
  });
});
