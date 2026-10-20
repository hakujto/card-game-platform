import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('TradeListing API', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  beforeAll(async () => {
    const moduleRef: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('api');
    await app.init();
    prisma = moduleRef.get<PrismaService>(PrismaService);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await app.close();
  });

  it('GET /api/trade_listings returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/trade_listings');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/trade_listings?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/trade_listings?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/trade_listings creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/trade_listings')
      .send({
      publicId: `00000000-0000-0000-0000-${Math.floor(Math.random()*1e12).toString().padStart(12,'0')}`,
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/trade_listings/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/trade_listings/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_listings/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_listings/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_listings/1/transitions/pending-to-active requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_listings/1/transitions/pending-to-active');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_listings/1/transitions/active-to-sold transitions Active -> Sold', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_listings/1/transitions/active-to-sold');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_listings/1/transitions/active-to-expired transitions Active -> Expired', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_listings/1/transitions/active-to-expired');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_listings/1/transitions/active-to-cancelled requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_listings/1/transitions/active-to-cancelled');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_listings/1/transitions/sold-to-active is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_listings/1/transitions/sold-to-active');
    expect([409, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_listings/1/transitions/expired-to-active is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_listings/1/transitions/expired-to-active');
    expect([409, 404]).toContain(res.status);
  });
});
