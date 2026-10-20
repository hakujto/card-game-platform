import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('OrderItem API', () => {
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

  it('GET /api/order_items returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/order_items');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/order_items creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/order_items')
      .send({
      quantity: 1,
      priceAtPurchase: 1.00
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/order_items/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/order_items/1');
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/order_items/:id returns 204 or 404', async () => {
    const res = await request(app.getHttpServer()).delete('/api/order_items/1');
    expect([204, 404]).toContain(res.status);
  });

});
