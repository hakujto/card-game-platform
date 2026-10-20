import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class TradeDisputeService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.tradeDispute.findMany();
  }

  async findOne(id: number) {
    return this.prisma.tradeDispute.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.tradeDispute.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.tradeDispute.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.tradeDispute.delete({ where: { id } });
  }

  async escalate(id: number): Promise<void> {
    const entity = await this.prisma.tradeDispute.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeDispute not found: ' + id);
    // TODO: implement escalate domain logic
  }
  async resolve(id: number, resolutionText: string): Promise<void> {
    const entity = await this.prisma.tradeDispute.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeDispute not found: ' + id);
    // TODO: implement resolve domain logic
  }
  async close_resolved(id: number): Promise<void> {
    const entity = await this.prisma.tradeDispute.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeDispute not found: ' + id);
    // TODO: implement close_resolved domain logic
  }
  async review(id: number): Promise<void> {
    const entity = await this.prisma.tradeDispute.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeDispute not found: ' + id);
    // TODO: implement review domain logic
  }
}
