import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Season API', () => {
  it('GET /api/seasons returns 200', async () => {
    const res = await request(app).get('/api/seasons');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/seasons creates entity', async () => {
    const res = await request(app)
      .post('/api/seasons')
      .send({
      name: 'test',
      startDate: '2024-01-01',
      endDate: '2024-01-01',
      isActive: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/seasons/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/seasons/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/seasons/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/seasons/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/seasons/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/seasons/1');
    expect([204, 404]).toContain(res.status);
  });
});
