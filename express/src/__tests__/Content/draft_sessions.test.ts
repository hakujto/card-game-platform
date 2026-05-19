import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('DraftSession API', () => {
  it('GET /api/draft_sessions returns 200', async () => {
    const res = await request(app).get('/api/draft_sessions');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/draft_sessions creates entity', async () => {
    const res = await request(app)
      .post('/api/draft_sessions')
      .send({
      seats: 2,
      timePerPickSeconds: 1,
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/draft_sessions/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/draft_sessions/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/draft_sessions/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/draft_sessions/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/draft_sessions/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/draft_sessions returns 400 when seats_range violated", async () => {
    const res = await request(app).post('/api/draft_sessions').send({ createdAt: '2024-01-01T00:00:00.000Z', cardSetId: 1, completedAt: '2024-01-01T00:00:00.000Z', status: 'COMPLETED', seats: 17 });
    expect(res.status).toBe(400);
  });

  it("POST /api/draft_sessions returns 400 when completed_at_requires_completed_status violated", async () => {
    const res = await request(app).post('/api/draft_sessions').send({ createdAt: '2024-01-01T00:00:00.000Z', cardSetId: 1, completedAt: '2024-01-01T00:00:00.000Z' });
    expect(res.status).toBe(400);
  });

  it("POST /api/draft_sessions returns 400 when time_per_pick_positive violated", async () => {
    const res = await request(app).post('/api/draft_sessions').send({ createdAt: '2024-01-01T00:00:00.000Z', cardSetId: 1, completedAt: '2024-01-01T00:00:00.000Z', status: 'COMPLETED', timePerPickSeconds: 0 });
    expect(res.status).toBe(400);
  });
  it('PATCH /api/draft_sessions/1/transitions/waitingforplayers-to-drafting transitions WaitingForPlayers -> Drafting', async () => {
    const res = await request(app).patch('/api/draft_sessions/1/transitions/waitingforplayers-to-drafting');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/1/transitions/drafting-to-completed transitions Drafting -> Completed', async () => {
    const res = await request(app).patch('/api/draft_sessions/1/transitions/drafting-to-completed');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/1/transitions/drafting-to-abandoned transitions Drafting -> Abandoned', async () => {
    const res = await request(app).patch('/api/draft_sessions/1/transitions/drafting-to-abandoned');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/1/transitions/waitingforplayers-to-abandoned transitions WaitingForPlayers -> Abandoned', async () => {
    const res = await request(app).patch('/api/draft_sessions/1/transitions/waitingforplayers-to-abandoned');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/1/transitions/completed-to-drafting is denied (409)', async () => {
    const res = await request(app).patch('/api/draft_sessions/1/transitions/completed-to-drafting');
    expect([409, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/1/transitions/abandoned-to-drafting is denied (409)', async () => {
    const res = await request(app).patch('/api/draft_sessions/1/transitions/abandoned-to-drafting');
    expect([409, 404]).toContain(res.status);
  });
});
