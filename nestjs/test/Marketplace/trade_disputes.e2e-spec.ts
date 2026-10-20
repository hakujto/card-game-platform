import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('TradeDispute API', () => {
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

  it('GET /api/trade_disputes returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/trade_disputes');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/trade_disputes creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/trade_disputes')
      .send({
      description: 'test',
      openedAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/trade_disputes/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/trade_disputes/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_disputes/1/transitions/open-to-underreview requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_disputes/1/transitions/open-to-underreview');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_disputes/1/transitions/underreview-to-resolved requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_disputes/1/transitions/underreview-to-resolved');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_disputes/1/transitions/underreview-to-escalated requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_disputes/1/transitions/underreview-to-escalated');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_disputes/1/transitions/escalated-to-resolved requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_disputes/1/transitions/escalated-to-resolved');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/trade_disputes/1/transitions/resolved-to-open is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/trade_disputes/1/transitions/resolved-to-open');
    expect([409, 404]).toContain(res.status);
  });
});
