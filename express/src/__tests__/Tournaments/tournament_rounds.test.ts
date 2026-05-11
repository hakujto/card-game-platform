import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('TournamentRound API', () => {
  it('GET /api/tournament_rounds returns 200', async () => {
    const res = await request(app).get('/api/tournament_rounds');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/tournament_rounds creates entity', async () => {
    const res = await request(app)
      .post('/api/tournament_rounds')
      .send({
      roundNumber: 1,
      timeLimitMinutes: 1
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/tournament_rounds/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/tournament_rounds/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/tournament_rounds/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/tournament_rounds/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/tournament_rounds/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/tournament_rounds/1');
    expect([204, 404]).toContain(res.status);
  });
});
