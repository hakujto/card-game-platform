import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('AwardedPrize API', () => {
  it('GET /api/awarded_prizes returns 200', async () => {
    const res = await request(app).get('/api/awarded_prizes');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/awarded_prizes creates entity', async () => {
    const res = await request(app)
      .post('/api/awarded_prizes')
      .send({
      finalPlacement: 1,
      awardedAt: '2024-01-01T00:00:00.000Z',
      claimed: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/awarded_prizes/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/awarded_prizes/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/awarded_prizes/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/awarded_prizes/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/awarded_prizes/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/awarded_prizes/1');
    expect([204, 404]).toContain(res.status);
  });
});
