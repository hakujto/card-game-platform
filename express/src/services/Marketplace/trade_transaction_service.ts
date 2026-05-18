import { prisma } from '../../lib/prisma.js';

export class TradeTransactionService {
  async findAll() {
    return prisma.tradeTransaction.findMany();
  }

  async findOne(id: number) {
    return prisma.tradeTransaction.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tradeTransaction.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tradeTransaction.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tradeTransaction.delete({ where: { id } });
  }

  async seller_net(): Promise<number> {
    throw new Error('seller_net not implemented');
  }
  async complete(id: number): Promise<void> {
    const entity = await prisma.tradeTransaction.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeTransaction not found: ' + id);
    // TODO: implement complete domain logic
    throw new Error('complete not implemented');
  }

  async refund(id: number): Promise<void> {
    const entity = await prisma.tradeTransaction.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeTransaction not found: ' + id);
    // TODO: implement refund domain logic
    throw new Error('refund not implemented');
  }

  async open_dispute(id: number, reason: string): Promise<void> {
    const entity = await prisma.tradeTransaction.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeTransaction not found: ' + id);
    // TODO: implement open_dispute domain logic
    throw new Error('open_dispute not implemented');
  }
}
