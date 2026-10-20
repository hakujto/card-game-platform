import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('TournamentPrize API', () => {
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

  it('GET /api/tournament_prizes returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/tournament_prizes');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/tournament_prizes creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/tournament_prizes')
      .send({
      placementFrom: 1,
      placementTo: 1
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/tournament_prizes/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/tournament_prizes/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/tournament_prizes/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/tournament_prizes/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/tournament_prizes/:id returns 204 or 404', async () => {
    const res = await request(app.getHttpServer()).delete('/api/tournament_prizes/1');
    expect([204, 404]).toContain(res.status);
  });

});
