import { prisma } from '../../lib/prisma.js';

export class CardRulingService {
  async findAll() {
    return prisma.cardRuling.findMany();
  }

  async findOne(id: number) {
    return prisma.cardRuling.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.cardRuling.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.cardRuling.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.cardRuling.delete({ where: { id } });
  }
}
