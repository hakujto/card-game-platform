import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('DraftSession API', () => {
  it('GET /api/draft_sessions returns 200', async () => {
    const res = await request(app).get('/api/draft_sessions');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/draft_sessions creates entity', async () => {
    const res = await request(app)
      .post('/api/draft_sessions')
      .send({
      seats: 1,
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/draft_sessions/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/draft_sessions/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/draft_sessions/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/draft_sessions/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/draft_sessions/1');
    expect([204, 404]).toContain(res.status);
  });
});
