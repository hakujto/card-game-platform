import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Deck API', () => {
  it('GET /api/decks returns 200', async () => {
    const res = await request(app).get('/api/decks');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/decks creates entity', async () => {
    const res = await request(app)
      .post('/api/decks')
      .send({
      name: 'test',
      isPublic: true,
      isTournamentLegal: true,
      wins: 1,
      losses: 1,
      draws: 1,
      createdAt: '2024-01-01T00:00:00.000Z',
      updatedAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/decks/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/decks/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/decks/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/decks/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/decks/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/decks/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/decks returns 400 when wins_not_negative violated", async () => {
    const res = await request(app).post('/api/decks').send({ name: 'test', createdAt: '2024-01-01T00:00:00.000Z', updatedAt: '2024-01-01T00:00:00.000Z', playerId: 1, isTournamentLegal: true, isPublic: true, wins: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/decks returns 400 when losses_not_negative violated", async () => {
    const res = await request(app).post('/api/decks').send({ name: 'test', createdAt: '2024-01-01T00:00:00.000Z', updatedAt: '2024-01-01T00:00:00.000Z', playerId: 1, isTournamentLegal: true, isPublic: true, losses: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/decks returns 400 when draws_not_negative violated", async () => {
    const res = await request(app).post('/api/decks').send({ name: 'test', createdAt: '2024-01-01T00:00:00.000Z', updatedAt: '2024-01-01T00:00:00.000Z', playerId: 1, isTournamentLegal: true, isPublic: true, draws: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/decks returns 400 when tournament_legal_deck_must_be_validated violated", async () => {
    const res = await request(app).post('/api/decks').send({ name: 'test', createdAt: '2024-01-01T00:00:00.000Z', updatedAt: '2024-01-01T00:00:00.000Z', playerId: 1, isTournamentLegal: true, isPublic: false });
    expect(res.status).toBe(400);
  });
});
