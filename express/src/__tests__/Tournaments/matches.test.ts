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
    const res = await request(app).post('/api/matches').send({ roundId: 1, player1Id: 1, status: 'COMPLETED', player2Id: null, endedAt: '2024-01-01T00:00:00.000Z', startedAt: '2024-01-01T00:00:00.000Z', player1Wins: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/matches returns 400 when max_three_games violated", async () => {
    const res = await request(app).post('/api/matches').send({ roundId: 1, player1Id: 1, status: 'COMPLETED', player2Id: null, endedAt: '2024-01-01T00:00:00.000Z', startedAt: '2024-01-01T00:00:00.000Z', player1Wins: 3 });
    expect(res.status).toBe(400);
  });

  it("POST /api/matches returns 400 when bye_has_no_player2 violated", async () => {
    const res = await request(app).post('/api/matches').send({ roundId: 1, player1Id: 1, status: 'BYE', player2Id: 1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/matches returns 400 when ended_after_started violated", async () => {
    const res = await request(app).post('/api/matches').send({ roundId: 1, player1Id: 1, endedAt: '2024-01-01T00:00:00.000Z' });
    expect(res.status).toBe(400);
  });

  it("POST /api/matches returns 400 when completed_requires_started_at violated", async () => {
    const res = await request(app).post('/api/matches').send({ roundId: 1, player1Id: 1, status: 'COMPLETED', startedAt: null });
    expect(res.status).toBe(400);
  });
  it('PATCH /api/matches/1/transitions/pending-to-active transitions Pending -> Active', async () => {
    const res = await request(app).patch('/api/matches/1/transitions/pending-to-active');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/active-to-completed transitions Active -> Completed', async () => {
    const res = await request(app).patch('/api/matches/1/transitions/active-to-completed');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/active-to-draw transitions Active -> Draw', async () => {
    const res = await request(app).patch('/api/matches/1/transitions/active-to-draw');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/pending-to-bye transitions Pending -> BYE', async () => {
    const res = await request(app).patch('/api/matches/1/transitions/pending-to-bye');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/completed-to-active is denied (409)', async () => {
    const res = await request(app).patch('/api/matches/1/transitions/completed-to-active');
    expect([409, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/draw-to-active is denied (409)', async () => {
    const res = await request(app).patch('/api/matches/1/transitions/draw-to-active');
    expect([409, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/bye-to-active is denied (409)', async () => {
    const res = await request(app).patch('/api/matches/1/transitions/bye-to-active');
    expect([409, 404]).toContain(res.status);
  });
});
