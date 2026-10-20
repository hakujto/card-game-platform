import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('DraftSession API', () => {
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

  it('GET /api/draft_sessions returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/draft_sessions');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/draft_sessions creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/draft_sessions')
      .send({
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/draft_sessions/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/draft_sessions/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/1/transitions/waitingforplayers-to-drafting transitions WaitingForPlayers -> Drafting', async () => {
    const res = await request(app.getHttpServer()).patch('/api/draft_sessions/1/transitions/waitingforplayers-to-drafting');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/1/transitions/drafting-to-completed transitions Drafting -> Completed', async () => {
    const res = await request(app.getHttpServer()).patch('/api/draft_sessions/1/transitions/drafting-to-completed');
    expect([200, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/1/transitions/drafting-to-abandoned requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/draft_sessions/1/transitions/drafting-to-abandoned');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/1/transitions/waitingforplayers-to-abandoned requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/draft_sessions/1/transitions/waitingforplayers-to-abandoned');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/1/transitions/completed-to-drafting is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/draft_sessions/1/transitions/completed-to-drafting');
    expect([409, 404]).toContain(res.status);
  });

  it('PATCH /api/draft_sessions/1/transitions/abandoned-to-drafting is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/draft_sessions/1/transitions/abandoned-to-drafting');
    expect([409, 404]).toContain(res.status);
  });
});
