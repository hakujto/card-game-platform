import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('DeckTag API', () => {
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

  it('GET /api/deck_tags returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/deck_tags');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/deck_tags?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/deck_tags?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/deck_tags creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/deck_tags')
      .send({
      name: 'test'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/deck_tags/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/deck_tags/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/deck_tags/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/deck_tags/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/deck_tags/:id returns 204 or 404', async () => {
    const res = await request(app.getHttpServer()).delete('/api/deck_tags/1');
    expect([204, 404]).toContain(res.status);
  });

});
