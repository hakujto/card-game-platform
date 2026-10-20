import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('Achievement API', () => {
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

  it('GET /api/achievements returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/achievements');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/achievements?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/achievements?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/achievements creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/achievements')
      .send({
      name: 'test',
      description: 'test'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/achievements/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/achievements/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/achievements/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/achievements/1').send({});
    expect([200, 404]).toContain(res.status);
  });

});
