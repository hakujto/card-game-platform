import request from 'supertest';
import { app } from '../../app.js';
import { prisma } from '../../lib/prisma.js';

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
      isBanned: false,
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

  it("POST /api/cards returns 400 when creature_requires_stats violated", async () => {
    const res = await request(app).post('/api/cards').send({ name: 'test', manaColors: 'WHITE', description: 'test', legalFormats: "message", setId: 1, cardType: 'CREATURE', attack: null });
    expect(res.status).toBe(400);
  });

  it("POST /api/cards returns 400 when planeswalker_requires_loyalty violated", async () => {
    const res = await request(app).post('/api/cards').send({ name: 'test', manaColors: 'WHITE', description: 'test', legalFormats: "message", setId: 1, cardType: 'PLANESWALKER', loyalty: null });
    expect(res.status).toBe(400);
  });

  it("POST /api/cards returns 400 when spell_or_artifact_no_loyalty violated", async () => {
    const res = await request(app).post('/api/cards').send({ name: 'test', manaColors: 'WHITE', description: 'test', legalFormats: "message", setId: 1, loyalty: 1 });
    expect(res.status).toBe(400);
  });

  it("POST /api/cards returns 400 when mana_cost_range violated", async () => {
    const res = await request(app).post('/api/cards').send({ name: 'test', manaColors: 'WHITE', description: 'test', setId: 1, cardType: 'PLANESWALKER', attack: 1, defense: 1, loyalty: null, isBanned: true, legalFormats: "message", manaCost: 21 });
    expect(res.status).toBe(400);
  });

  it("POST /api/cards returns 400 when power_level_range violated", async () => {
    const res = await request(app).post('/api/cards').send({ name: 'test', manaColors: 'WHITE', description: 'test', setId: 1, cardType: 'PLANESWALKER', attack: 1, defense: 1, loyalty: null, isBanned: true, legalFormats: "message", powerLevel: 11 });
    expect(res.status).toBe(400);
  });

  it("POST /api/cards returns 400 when not_banned_and_restricted violated", async () => {
    const res = await request(app).post('/api/cards').send({ name: 'test', manaColors: 'WHITE', description: 'test', setId: 1, cardType: 'PLANESWALKER', attack: 1, defense: 1, loyalty: null, legalFormats: "message", isBanned: true, isRestricted: true });
    expect(res.status).toBe(400);
  });

  it("POST /api/cards returns 400 when banned_card_not_in_legal_formats violated", async () => {
    const res = await request(app).post('/api/cards').send({ name: 'test', manaColors: 'WHITE', description: 'test', legalFormats: "message", setId: 1, isBanned: true });
    expect(res.status).toBe(400);
  });
});
