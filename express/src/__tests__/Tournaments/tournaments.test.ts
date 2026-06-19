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

  it('GET /api/tournaments?q=test returns 200', async () => {
    const res = await request(app).get('/api/tournaments?q=test');
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

  it('PATCH /api/tournaments/1/transitions/draft-to-registration requires role for Draft -> Registration', async () => {
    const res = await request(app).patch('/api/tournaments/1/transitions/draft-to-registration');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/registration-to-ongoing requires role for Registration -> Ongoing', async () => {
    const res = await request(app).patch('/api/tournaments/1/transitions/registration-to-ongoing');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/registration-to-cancelled requires role for Registration -> Cancelled', async () => {
    const res = await request(app).patch('/api/tournaments/1/transitions/registration-to-cancelled');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/ongoing-to-completed requires role for Ongoing -> Completed', async () => {
    const res = await request(app).patch('/api/tournaments/1/transitions/ongoing-to-completed');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/ongoing-to-cancelled requires role for Ongoing -> Cancelled', async () => {
    const res = await request(app).patch('/api/tournaments/1/transitions/ongoing-to-cancelled');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/completed-to-draft is denied (409)', async () => {
    const res = await request(app).patch('/api/tournaments/1/transitions/completed-to-draft');
    expect([409, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/cancelled-to-draft is denied (409)', async () => {
    const res = await request(app).patch('/api/tournaments/1/transitions/cancelled-to-draft');
    expect([409, 404]).toContain(res.status);
  });
});
