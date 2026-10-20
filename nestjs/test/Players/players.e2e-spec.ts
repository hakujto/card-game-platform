import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('Player API', () => {
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

  it('GET /api/players returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/players');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/players?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/players?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/players creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/players')
      .send({
      publicId: `00000000-0000-0000-0000-${Math.floor(Math.random()*1e12).toString().padStart(12,'0')}`,
      displayName: 'test_player_001',
      createdAt: '2024-01-01T00:00:00.000Z'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/players/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/players/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/players/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/players/1').send({ bio: 'test' });
    expect([200, 404]).toContain(res.status);
  });

});
