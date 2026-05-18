import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

afterAll(async () => { await prisma.$disconnect(); });

describe('Tradelisting API', () => {
  it('GET /api/tradelistings returns 200', async () => {
    const res = await request(app).get('/api/tradelistings');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/tradelistings creates entity', async () => {
    const res = await request(app)
      .post('/api/tradelistings')
      .send({
      foil: true,
      quantity: 1,
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/tradelistings/:id returns 200 or 404', async () => {
    const res = await request(app).get('/api/tradelistings/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/tradelistings/:id returns 200 or 404', async () => {
    const res = await request(app).patch('/api/tradelistings/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/tradelistings/:id returns 204 or 404', async () => {
    const res = await request(app).delete('/api/tradelistings/1');
    expect([204, 404]).toContain(res.status);
  });

  it("POST /api/tradelistings returns 400 when fixed_price_requires_asking_price violated", async () => {
    const res = await request(app).post('/api/tradelistings').send({ createdAt: '2024-01-01T00:00:00.000Z', sellerId: 1, cardId: 1, listingType: 'FIXEDPRICE', askingPrice: null });
    expect(res.status).toBe(400);
  });

  it("POST /api/tradelistings returns 400 when auction_requires_start_price_and_end_time violated", async () => {
    const res = await request(app).post('/api/tradelistings').send({ createdAt: '2024-01-01T00:00:00.000Z', sellerId: 1, cardId: 1, listingType: 'AUCTION', auctionStartPrice: null });
    expect(res.status).toBe(400);
  });

  it("POST /api/tradelistings returns 400 when quantity_positive violated", async () => {
    const res = await request(app).post('/api/tradelistings').send({ createdAt: '2024-01-01T00:00:00.000Z', sellerId: 1, cardId: 1, listingType: 'AUCTION', askingPrice: 0.00, auctionStartPrice: 0.00, auctionEndTime: '2024-01-01T00:00:00.000Z', quantity: 10000 });
    expect(res.status).toBe(400);
  });
});
