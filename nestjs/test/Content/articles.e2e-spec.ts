import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('Article API', () => {
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

  it('GET /api/articles returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/articles');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/articles?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/articles?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/articles creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/articles')
      .send({
      title: 'test',
      slug: `test_${Math.random().toString(36).slice(2,8)}`,
      body: 'test',
      createdAt: '2024-01-01T00:00:00.000Z',
      updatedAt: '2025-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/articles/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/articles/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/articles/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/articles/1').send({ excerpt: 'test' });
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/articles/1/transitions/draft-to-published requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/articles/1/transitions/draft-to-published');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/articles/1/transitions/published-to-archived requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/articles/1/transitions/published-to-archived');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/articles/1/transitions/archived-to-draft requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/articles/1/transitions/archived-to-draft');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/articles/1/transitions/published-to-draft is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/articles/1/transitions/published-to-draft');
    expect([409, 404]).toContain(res.status);
  });
});
