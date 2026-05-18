import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Match API', () => {
  it('GET /api/matches returns 200', async () => {
    const res = await request(app).get('/api/matches');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/matches creates entity', async () => {
    const res = await request(app)
      .post('/api/matches')
      .send({
      player1Wins: 1,
      player2Wins: 1
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/matches/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/matches/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/matches/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/matches/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/matches/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/matches returns 400 when wins_not_negative violated", async () => {
    const res = await request(app).post('/api/matches').send({ roundId: 1, player1Id: 1, status: 'BYE', player2Id: null, player1Wins: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/matches returns 400 when max_three_games violated", async () => {
    const res = await request(app).post('/api/matches').send({ roundId: 1, player1Id: 1, status: 'BYE', player2Id: null, player1Wins: 3 });
    expect(res.status).toBe(400);
  });

  it("POST /api/matches returns 400 when bye_has_no_player2 violated", async () => {
    const res = await request(app).post('/api/matches').send({ roundId: 1, player1Id: 1, status: 'BYE', player2Id: 1 });
    expect(res.status).toBe(400);
  });
});
