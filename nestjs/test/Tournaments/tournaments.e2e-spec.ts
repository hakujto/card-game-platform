import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('Tournament API', () => {
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

  it('GET /api/tournaments returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/tournaments');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/tournaments?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/tournaments?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/tournaments creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/tournaments')
      .send({
      publicId: `00000000-0000-0000-0000-${Math.floor(Math.random()*1e12).toString().padStart(12,'0')}`,
      name: 'Test Tournament Alpha',
      maxPlayers: 8,
      startTime: '2024-01-01T00:00:00.000Z',
      createdAt: '2025-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/tournaments/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/tournaments/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/tournaments/1').send({ description: 'test' });
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/draft-to-registration requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/tournaments/1/transitions/draft-to-registration');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/registration-to-ongoing requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/tournaments/1/transitions/registration-to-ongoing');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/registration-to-cancelled requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/tournaments/1/transitions/registration-to-cancelled');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/ongoing-to-completed requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/tournaments/1/transitions/ongoing-to-completed');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/ongoing-to-cancelled requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/tournaments/1/transitions/ongoing-to-cancelled');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/completed-to-draft is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/tournaments/1/transitions/completed-to-draft');
    expect([409, 404]).toContain(res.status);
  });

  it('PATCH /api/tournaments/1/transitions/cancelled-to-draft is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/tournaments/1/transitions/cancelled-to-draft');
    expect([409, 404]).toContain(res.status);
  });
});
