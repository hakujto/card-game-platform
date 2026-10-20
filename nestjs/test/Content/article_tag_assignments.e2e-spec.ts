import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('ArticleTagAssignment API', () => {
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

  it('GET /api/article_tag_assignments returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/article_tag_assignments');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/article_tag_assignments creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/article_tag_assignments')
      .send({});
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/article_tag_assignments/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/article_tag_assignments/1');
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/article_tag_assignments/:id returns 204 or 404', async () => {
    const res = await request(app.getHttpServer()).delete('/api/article_tag_assignments/1');
    expect([204, 404]).toContain(res.status);
  });

});
