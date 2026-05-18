import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Game API', () => {
  it('GET /api/games returns 200', async () => {
    const res = await request(app).get('/api/games');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/games creates entity', async () => {
    const res = await request(app)
      .post('/api/games')
      .send({
      gameNumber: 1
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/games/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/games/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/games/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/games/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/games/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/games/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/games returns 400 when game_number_range violated", async () => {
    const res = await request(app).post('/api/games').send({ matchId: 1, turnsPlayed: 1, durationSeconds: 1, winnerSide: 'PLAYER1', winnerId: 1, gameNumber: 4 });
    expect(res.status).toBe(400);
  });

  it("POST /api/games returns 400 when turns_played_positive violated", async () => {
    const res = await request(app).post('/api/games').send({ gameNumber: 1, matchId: 1, turnsPlayed: 0 });
    expect(res.status).toBe(400);
  });

  it("POST /api/games returns 400 when duration_positive violated", async () => {
    const res = await request(app).post('/api/games').send({ gameNumber: 1, matchId: 1, durationSeconds: 0 });
    expect(res.status).toBe(400);
  });

  it("POST /api/games returns 400 when draw_has_no_winner violated", async () => {
    const res = await request(app).post('/api/games').send({ gameNumber: 1, matchId: 1, winnerSide: 'DRAW', winnerId: 1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/games returns 400 when non_draw_requires_winner violated", async () => {
    const res = await request(app).post('/api/games').send({ gameNumber: 1, matchId: 1, winnerSide: 'PLAYER1', winnerId: null });
    expect(res.status).toBe(400);
  });
});
