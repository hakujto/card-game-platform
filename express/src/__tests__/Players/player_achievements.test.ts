import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('PlayerAchievement API', () => {
  it('GET /api/player_achievements returns 200', async () => {
    const res = await request(app).get('/api/player_achievements');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/player_achievements/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/player_achievements/1');
    expect([200, 404]).toContain(res.status);
  });

});
