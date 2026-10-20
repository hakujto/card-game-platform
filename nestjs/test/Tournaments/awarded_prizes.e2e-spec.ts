import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('AwardedPrize API', () => {
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

  it('GET /api/awarded_prizes returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/awarded_prizes');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/awarded_prizes/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/awarded_prizes/1');
    expect([200, 404]).toContain(res.status);
  });

});
