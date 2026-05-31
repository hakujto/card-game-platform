import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('DraftPick API', () => {
  it('GET /api/draft_picks returns 200', async () => {
    const res = await request(app).get('/api/draft_picks');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/draft_picks/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/draft_picks/1');
    expect([200, 404]).toContain(res.status);
  });

});
