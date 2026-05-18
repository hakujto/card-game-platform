import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('TournamentPrize API', () => {
  it('GET /api/tournament_prizes returns 200', async () => {
    const res = await request(app).get('/api/tournament_prizes');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/tournament_prizes creates entity', async () => {
    const res = await request(app)
      .post('/api/tournament_prizes')
      .send({
      placementFrom: 1,
      placementTo: 1,
      amount: 0.00,
      seasonPoints: 1
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/tournament_prizes/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/tournament_prizes/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/tournament_prizes/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/tournament_prizes/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/tournament_prizes/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/tournament_prizes/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/tournament_prizes returns 400 when placement_range_valid violated", async () => {
    const res = await request(app).post('/api/tournament_prizes').send({ placementFrom: 1, prizeType: 'CURRENCY', tournamentId: 1, placementTo: 0 });
    expect(res.status).toBe(400);
  });

  it("POST /api/tournament_prizes returns 400 when placement_from_positive violated", async () => {
    const res = await request(app).post('/api/tournament_prizes').send({ placementTo: 1, prizeType: 'CURRENCY', tournamentId: 1, placementFrom: 0 });
    expect(res.status).toBe(400);
  });

  it("POST /api/tournament_prizes returns 400 when amount_not_negative violated", async () => {
    const res = await request(app).post('/api/tournament_prizes').send({ placementFrom: 1, placementTo: 1, prizeType: 'CURRENCY', tournamentId: 1, amount: -1 });
    expect(res.status).toBe(400);
  });
});
