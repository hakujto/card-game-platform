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

  async price_change_percent(previousAvg: number): Promise<number> {
    throw new Error('price_change_percent not implemented');
  }

  async is_price_spike(thresholdPercent: number): Promise<boolean> {
    throw new Error('is_price_spike not implemented');
  }
}
