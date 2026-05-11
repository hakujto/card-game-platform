import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('TournamentJudge API', () => {
  it('GET /api/tournament_judges returns 200', async () => {
    const res = await request(app).get('/api/tournament_judges');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/tournament_judges creates entity', async () => {
    const res = await request(app)
      .post('/api/tournament_judges')
      .send({});
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/tournament_judges/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/tournament_judges/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/tournament_judges/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/tournament_judges/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/tournament_judges/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/tournament_judges/1');
    expect([204, 404]).toContain(res.status);
  });
});
