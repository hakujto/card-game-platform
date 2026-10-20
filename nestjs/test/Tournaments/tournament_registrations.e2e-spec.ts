import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('TournamentRegistration API', () => {
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

  it('GET /api/tournament_registrations returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/tournament_registrations');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/tournament_registrations creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/tournament_registrations')
      .send({
      registeredAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/tournament_registrations/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/tournament_registrations/1').set('X-User-Id', '1');
    expect([200, 404, 403]).toContain(res.status);
  });

});
