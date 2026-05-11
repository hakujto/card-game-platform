import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('DeckTag API', () => {
  it('GET /api/deck_tags returns 200', async () => {
    const res = await request(app).get('/api/deck_tags');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/deck_tags creates entity', async () => {
    const res = await request(app)
      .post('/api/deck_tags')
      .send({
      name: 'test'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/deck_tags/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/deck_tags/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/deck_tags/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/deck_tags/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/deck_tags/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/deck_tags/1');
    expect([204, 404]).toContain(res.status);
  });
});
