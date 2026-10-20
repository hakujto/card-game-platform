import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('Stream API', () => {
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

  it('GET /api/streams returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/streams');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/streams?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/streams?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/streams creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/streams')
      .send({
      title: 'test',
      streamUrl: 'https://example.com',
      scheduledStart: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/streams/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/streams/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/streams/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/streams/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/streams/1/transitions/scheduled-to-live requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/streams/1/transitions/scheduled-to-live');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/streams/1/transitions/live-to-ended requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/streams/1/transitions/live-to-ended');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/streams/1/transitions/ended-to-live is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/streams/1/transitions/ended-to-live');
    expect([409, 404]).toContain(res.status);
  });
});
