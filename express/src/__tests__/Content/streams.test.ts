import request from 'supertest';
import { app } from '../../../app.js';
import { prisma } from '../../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Stream API', () => {
  it('GET /api/streams returns 200', async () => {
    const res = await request(app).get('/api/streams');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/streams creates entity', async () => {
    const res = await request(app)
      .post('/api/streams')
      .send({
      title: 'test',
      streamUrl: 'https://example.com',
      viewerCountPeak: 1,
      scheduledStart: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/streams/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/streams/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/streams/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/streams/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/streams/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/streams/1');
    expect([204, 404]).toContain(res.status);
  });
});
