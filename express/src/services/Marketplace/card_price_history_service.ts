import { prisma } from '../../lib/prisma.js';

export class CardPriceHistoryService {
  async findAll() {
    return prisma.cardPriceHistory.findMany();
  }

  async findOne(id: number) {
    return prisma.cardPriceHistory.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.cardPriceHistory.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.cardPriceHistory.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.cardPriceHistory.delete({ where: { id } });
  }
}
