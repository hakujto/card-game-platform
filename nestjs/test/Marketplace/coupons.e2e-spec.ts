import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('Coupon API', () => {
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

  it('GET /api/coupons returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/coupons');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/coupons?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/coupons?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/coupons creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/coupons')
      .send({
      code: `test_${Math.random().toString(36).slice(2,8)}`,
      discountValue: 0.01,
      validFrom: '2024-01-01T00:00:00.000Z',
      validUntil: '2025-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/coupons/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/coupons/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/coupons/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/coupons/1').send({});
    expect([200, 404]).toContain(res.status);
  });

});
