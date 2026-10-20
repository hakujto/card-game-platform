import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CardPriceHistoryService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.cardPriceHistory.findMany();
  }

  async findOne(id: number) {
    return this.prisma.cardPriceHistory.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.cardPriceHistory.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.cardPriceHistory.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.cardPriceHistory.delete({ where: { id } });
  }

  async price_change_percent(id: number, previousAvg: number): Promise<number> {
    const entity = await this.prisma.cardPriceHistory.findUnique({ where: { id } });
    if (!entity) throw new Error('CardPriceHistory not found: ' + id);
    // TODO: implement price_change_percent domain logic
    return undefined as any;
  }
  async is_price_spike(id: number, thresholdPercent: number): Promise<boolean> {
    const entity = await this.prisma.cardPriceHistory.findUnique({ where: { id } });
    if (!entity) throw new Error('CardPriceHistory not found: ' + id);
    // TODO: implement is_price_spike domain logic
    return undefined as any;
  }
}
