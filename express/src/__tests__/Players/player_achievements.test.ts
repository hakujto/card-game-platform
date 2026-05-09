import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('PlayerAchievement API', () => {
  it('GET /api/player_achievements returns 200', async () => {
    const res = await request(app).get('/api/player_achievements');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/player_achievements creates entity', async () => {
    const res = await request(app)
      .post('/api/player_achievements')
      .send({
      earnedAt: '2024-01-01T00:00:00.000Z',
      progress: 1,
      isCompleted: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/player_achievements/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/player_achievements/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/player_achievements/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/player_achievements/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/player_achievements/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/player_achievements/1');
    expect([204, 404]).toContain(res.status);
  });
});
