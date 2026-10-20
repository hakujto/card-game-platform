import request from 'supertest';
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { AppModule } from '../../src/app.module';
import { PrismaService } from '../../src/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () { return this.toString(); };

describe('CraftingRecipe API', () => {
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

  it('GET /api/crafting_recipes returns 200', async () => {
    const res = await request(app.getHttpServer()).get('/api/crafting_recipes');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/crafting_recipes creates entity', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/crafting_recipes')
      .send({
      dustCost: 1
    });
    expect([200, 201]).toContain(res.status);
  });

  it('GET /api/crafting_recipes/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).get('/api/crafting_recipes/1');
    expect([200, 404]).toContain(res.status);
  });

  it('PATCH /api/crafting_recipes/:id returns 200 or 404', async () => {
    const res = await request(app.getHttpServer()).patch('/api/crafting_recipes/1').send({});
    expect([200, 404]).toContain(res.status);
  });

});
