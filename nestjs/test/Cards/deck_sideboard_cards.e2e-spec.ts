import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('DeckSideboardCard API', () => {
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

  it('GET /api/deck_sideboard_cards returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/deck_sideboard_cards');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/deck_sideboard_cards creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/deck_sideboard_cards')
      .send({});
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/deck_sideboard_cards/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/deck_sideboard_cards/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/deck_sideboard_cards/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/deck_sideboard_cards/1').send({});
    expect([200, 404]).toContain(res.status);
  });

  it('DELETE /api/deck_sideboard_cards/:id returns 204 or 404', async () => {
    const res = await request(app.getHttpServer()).delete('/api/deck_sideboard_cards/1');
    expect([204, 404]).toContain(res.status);
  });

});
