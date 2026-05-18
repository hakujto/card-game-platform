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

  async price_change_percent(id: number, previousAvg: number): Promise<number> {
    const entity = await prisma.cardPriceHistory.findUnique({ where: { id } });
    if (!entity) throw new Error('CardPriceHistory not found: ' + id);
    // TODO: implement price_change_percent domain logic
    throw new Error('price_change_percent not implemented');
  }

  async is_price_spike(id: number, thresholdPercent: number): Promise<boolean> {
    const entity = await prisma.cardPriceHistory.findUnique({ where: { id } });
    if (!entity) throw new Error('CardPriceHistory not found: ' + id);
    // TODO: implement is_price_spike domain logic
    throw new Error('is_price_spike not implemented');
  }
}
