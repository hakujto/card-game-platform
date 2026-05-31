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

  it('GET /api/player_season_statses/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/player_season_statses/1');
    expect([200, 404]).toContain(res.status);
  });

});
