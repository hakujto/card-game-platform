import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Tournament API', () => {
  it('GET /api/tournaments returns 200', async () => {
    const res = await request(app).get('/api/tournaments');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/tournaments creates entity', async () => {
    const res = await request(app)
      .post('/api/tournaments')
      .send({
      name: 'test',
      maxPlayers: 2,
      entryFee: 0.00,
      prizePool: 0.00,
      startTime: '2024-01-01T00:00:00.000Z',
      isOnline: true,
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/tournaments/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/tournaments/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/tournaments/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/tournaments/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/tournaments/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/tournaments returns 400 when max_players_positive violated", async () => {
    const res = await request(app).post('/api/tournaments').send({ name: 'test', startTime: '2024-01-01T00:00:00.000Z', createdAt: '2024-01-01T00:00:00.000Z', seasonId: 1, organizerId: 1, endTime: '2024-01-01T00:00:00.000Z', maxPlayers: 513 });
    expect(res.status).toBe(400);
  });

  it("POST /api/tournaments returns 400 when entry_fee_not_negative violated", async () => {
    const res = await request(app).post('/api/tournaments').send({ name: 'test', maxPlayers: 2, startTime: '2024-01-01T00:00:00.000Z', createdAt: '2024-01-01T00:00:00.000Z', seasonId: 1, organizerId: 1, endTime: '2024-01-01T00:00:00.000Z', entryFee: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/tournaments returns 400 when prize_pool_not_negative violated", async () => {
    const res = await request(app).post('/api/tournaments').send({ name: 'test', maxPlayers: 2, startTime: '2024-01-01T00:00:00.000Z', createdAt: '2024-01-01T00:00:00.000Z', seasonId: 1, organizerId: 1, endTime: '2024-01-01T00:00:00.000Z', prizePool: -1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/tournaments returns 400 when end_time_after_start violated", async () => {
    const res = await request(app).post('/api/tournaments').send({ name: 'test', maxPlayers: 2, startTime: '2024-01-01T00:00:00.000Z', createdAt: '2024-01-01T00:00:00.000Z', seasonId: 1, organizerId: 1, endTime: '2024-01-01T00:00:00.000Z' });
    expect(res.status).toBe(400);
  });
});
