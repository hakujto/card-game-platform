import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('TournamentRegistration API', () => {
  it('GET /api/tournament_registrations returns 200', async () => {
    const res = await request(app).get('/api/tournament_registrations');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/tournament_registrations creates entity', async () => {
    const res = await request(app)
      .post('/api/tournament_registrations')
      .send({
      pointsEarned: 1,
      registeredAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/tournament_registrations/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/tournament_registrations/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/tournament_registrations/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/tournament_registrations/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/tournament_registrations/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/tournament_registrations/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/tournament_registrations returns 400 when points_earned_not_negative violated", async () => {
    const res = await request(app).post('/api/tournament_registrations').send({ registeredAt: '2024-01-01T00:00:00.000Z', tournamentId: 1, playerId: 1, deckId: 1, finalStanding: 1, seed: 1, pointsEarned: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/tournament_registrations returns 400 when final_standing_positive violated", async () => {
    const res = await request(app).post('/api/tournament_registrations').send({ registeredAt: '2024-01-01T00:00:00.000Z', tournamentId: 1, playerId: 1, deckId: 1, finalStanding: 0 });
    expect(res.status).toBe(400);
  });

  it("POST /api/tournament_registrations returns 400 when seed_positive violated", async () => {
    const res = await request(app).post('/api/tournament_registrations').send({ registeredAt: '2024-01-01T00:00:00.000Z', tournamentId: 1, playerId: 1, deckId: 1, seed: 0 });
    expect(res.status).toBe(400);
  });
});
