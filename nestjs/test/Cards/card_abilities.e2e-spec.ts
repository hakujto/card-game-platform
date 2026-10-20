import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('CardAbility API', () => {
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

  it('GET /api/card_abilities returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/card_abilities');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/card_abilities?q=test returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/card_abilities?q=test');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/card_abilities creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/card_abilities')
      .send({
      abilityText: 'test'
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/card_abilities/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/card_abilities/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/card_abilities/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/card_abilities/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/card_abilities/:id returns 204 or 404', async () => {
    const res = await request(app.getHttpServer()).delete('/api/card_abilities/1');
    expect([204, 404]).toContain(res.status);
  });

});
