import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('CardRuling API', () => {
  it('GET /api/card_rulings returns 200', async () => {
    const res = await request(app).get('/api/card_rulings');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/card_rulings creates entity', async () => {
    const res = await request(app)
      .post('/api/card_rulings')
      .send({
      rulingText: 'test',
      publishedAt: '2024-01-01',
      source: 'test'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/card_rulings/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/card_rulings/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/card_rulings/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/card_rulings/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/card_rulings/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/card_rulings/1');
    expect([204, 404]).toContain(res.status);
  });

});
