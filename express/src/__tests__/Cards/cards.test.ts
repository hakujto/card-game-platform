import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Card API', () => {
  it('GET /api/cards returns 200', async () => {
    const res = await request(app).get('/api/cards');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/cards creates entity', async () => {
    const res = await request(app)
      .post('/api/cards')
      .send({
      name: 'test',
      manaCost: 1,
      description: 'test',
      isBanned: true,
      isRestricted: true,
      powerLevel: 1
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/cards/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/cards/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/cards/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/cards/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/cards/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/cards/1');
    expect([204, 404]).toContain(res.status);
  });
});
