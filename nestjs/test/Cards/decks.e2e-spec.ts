import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('Deck API', () => {
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

  it('GET /api/decks returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/decks');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/decks?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/decks?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/decks creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/decks')
      .send({
      name: 'test',
      createdAt: '2024-01-01T00:00:00.000Z',
      updatedAt: '2025-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/decks/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/decks/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/decks/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/decks/1').send({ name: 'test' });
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/decks/:id returns 204 or 404', async () => {
    const res = await request(app.getHttpServer()).delete('/api/decks/1');
    expect([204, 404]).toContain(res.status);
  });

});
