import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('Card API', () => {
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

  it('GET /api/cards returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/cards');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/cards?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/cards?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/cards creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/cards')
      .send({
      publicId: `00000000-0000-0000-0000-${Math.floor(Math.random()*1e12).toString().padStart(12,'0')}`,
      name: 'Test Lightning Bolt',
      description: 'test'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/cards/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/cards/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/cards/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/cards/1').send({ flavorText: 'test' });
    expect([200, 404]).toContain(res.status);
  });

});
