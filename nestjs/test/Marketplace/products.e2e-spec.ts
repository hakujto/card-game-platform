import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('Product API', () => {
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

  it('GET /api/products returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/products');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/products?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/products?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/products creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/products')
      .send({
      name: 'test',
      price: 1.00
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/products/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/products/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/products/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/products/1').send({ description: 'test' });
    expect([200, 404]).toContain(res.status);
  });

});
