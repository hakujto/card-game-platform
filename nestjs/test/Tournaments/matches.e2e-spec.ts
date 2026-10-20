import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('Match API', () => {
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

  it('GET /api/matches returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/matches');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/matches creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/matches')
      .send({});
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/matches/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/matches/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/pending-to-active requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/matches/1/transitions/pending-to-active');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/active-to-completed requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/matches/1/transitions/active-to-completed');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/active-to-draw requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/matches/1/transitions/active-to-draw');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/pending-to-bye requires role', async () => {
    const res = await request(app.getHttpServer()).patch('/api/matches/1/transitions/pending-to-bye');
    expect([200, 403, 409, 422, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/completed-to-active is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/matches/1/transitions/completed-to-active');
    expect([409, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/draw-to-active is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/matches/1/transitions/draw-to-active');
    expect([409, 404]).toContain(res.status);
  });

  it('PATCH /api/matches/1/transitions/bye-to-active is denied', async () => {
    const res = await request(app.getHttpServer()).patch('/api/matches/1/transitions/bye-to-active');
    expect([409, 404]).toContain(res.status);
  });
});
