import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('CardSet API', () => {
  it('GET /api/card_sets returns 200', async () => {
    const res = await request(app).get('/api/card_sets');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/card_sets creates entity', async () => {
    const res = await request(app)
      .post('/api/card_sets')
      .send({
      name: 'test',
      code: 'test',
      releaseDate: '2024-01-01',
      totalCards: 1,
      isRotated: true
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/card_sets/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/card_sets/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/card_sets/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/card_sets/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/card_sets/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/card_sets/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/card_sets returns 400 when total_cards_positive violated", async () => {
    const res = await request(app).post('/api/card_sets').send({ name: 'test', code: 'test', releaseDate: '2024-01-01', rotationDate: '2024-01-01', isRotated: true, totalCards: 0 });
    expect(res.status).toBe(400);
  });

  it("POST /api/card_sets returns 400 when rotation_date_after_release violated", async () => {
    const res = await request(app).post('/api/card_sets').send({ name: 'test', code: 'test', releaseDate: '2024-01-01', totalCards: 1, rotationDate: '2024-01-01' });
    expect(res.status).toBe(400);
  });

  it("POST /api/card_sets returns 400 when rotated_set_has_rotation_date violated", async () => {
    const res = await request(app).post('/api/card_sets').send({ name: 'test', code: 'test', releaseDate: '2024-01-01', totalCards: 1, isRotated: true, rotationDate: null });
    expect(res.status).toBe(400);
  });
});
