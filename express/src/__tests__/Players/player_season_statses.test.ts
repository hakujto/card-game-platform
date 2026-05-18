import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('PlayerSeasonStats API', () => {
  it('GET /api/player_season_statses returns 200', async () => {
    const res = await request(app).get('/api/player_season_statses');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/player_season_statses creates entity', async () => {
    const res = await request(app)
      .post('/api/player_season_statses')
      .send({
      wins: 1,
      losses: 1,
      draws: 1,
      tournamentWins: 1,
      seasonPoints: 1
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/player_season_statses/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/player_season_statses/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/player_season_statses/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/player_season_statses/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/player_season_statses/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/player_season_statses/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/player_season_statses returns 400 when wins_not_negative violated", async () => {
    const res = await request(app).post('/api/player_season_statses').send({ playerId: 1, seasonId: 1, wins: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/player_season_statses returns 400 when losses_not_negative violated", async () => {
    const res = await request(app).post('/api/player_season_statses').send({ playerId: 1, seasonId: 1, losses: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/player_season_statses returns 400 when tournament_wins_not_negative violated", async () => {
    const res = await request(app).post('/api/player_season_statses').send({ playerId: 1, seasonId: 1, tournamentWins: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/player_season_statses returns 400 when season_points_not_negative violated", async () => {
    const res = await request(app).post('/api/player_season_statses').send({ playerId: 1, seasonId: 1, seasonPoints: -1 });
    expect(res.status).toBe(400);
  });
});
