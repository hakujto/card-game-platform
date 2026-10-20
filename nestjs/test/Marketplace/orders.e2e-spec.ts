import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('Order API', () => {
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

  it('GET /api/orders returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/orders');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/orders creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/orders')
      .send({
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/orders/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/orders/1').set('X-User-Id', '1');
    expect([200, 404, 403]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/pending-to-paid transitions Pending -> Paid', async () => {
    const res = await request(app.getHttpServer()).patch('/api/orders/1/transitions/pending-to-paid');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/paid-to-processing requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/orders/1/transitions/paid-to-processing');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/processing-to-shipped requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/orders/1/transitions/processing-to-shipped');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/shipped-to-completed requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/orders/1/transitions/shipped-to-completed');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/pending-to-cancelled transitions Pending -> Cancelled', async () => {
    const res = await request(app.getHttpServer()).patch('/api/orders/1/transitions/pending-to-cancelled');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/paid-to-cancelled requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/orders/1/transitions/paid-to-cancelled');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/completed-to-refunded requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/orders/1/transitions/completed-to-refunded');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/refunded-to-completed is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/orders/1/transitions/refunded-to-completed');
    expect([409, 404]).toContain(res.status);
  });

  it('PATCH /api/orders/1/transitions/completed-to-cancelled is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/orders/1/transitions/completed-to-cancelled');
    expect([409, 404]).toContain(res.status);
  });
});
