import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Achievement API', () => {
  it('GET /api/achievements returns 200', async () => {
    const res = await request(app).get('/api/achievements');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/achievements creates entity', async () => {
    const res = await request(app)
      .post('/api/achievements')
      .send({
      name: 'test',
      description: 'test',
      points: 1,
      isHidden: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/achievements/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/achievements/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/achievements/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/achievements/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/achievements/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/achievements/1');
    expect([204, 404]).toContain(res.status);
  });
});
