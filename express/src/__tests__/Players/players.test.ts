import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Player API', () => {
  it('GET /api/players returns 200', async () => {
    const res = await request(app).get('/api/players');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/players creates entity', async () => {
    const res = await request(app)
      .post('/api/players')
      .send({
      displayName: 'test',
      rating: 1,
      peakRating: 1,
      isVerified: true,
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/players/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/players/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/players/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/players/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/players/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/players/1');
    expect([204, 404]).toContain(res.status);
  });
});
