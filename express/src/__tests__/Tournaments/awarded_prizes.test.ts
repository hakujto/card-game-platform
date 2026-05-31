import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('AwardedPrize API', () => {
  it('GET /api/awarded_prizes returns 200', async () => {
    const res = await request(app).get('/api/awarded_prizes');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/awarded_prizes/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/awarded_prizes/1');
    expect([200, 404]).toContain(res.status);
  });

});
