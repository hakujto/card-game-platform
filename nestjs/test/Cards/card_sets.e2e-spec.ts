import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('CardSet API', () => {
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

  it('GET /api/card_sets returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/card_sets');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/card_sets?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/card_sets?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/card_sets creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/card_sets')
      .send({
      name: 'test',
      code: `AB${Math.random().toString(36).slice(2,4).toUpperCase()}`,
      releaseDate: '2024-01-01',
      totalCards: 1
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/card_sets/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/card_sets/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/card_sets/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/card_sets/1').send({});
    expect([200, 404]).toContain(res.status);
  });

});
