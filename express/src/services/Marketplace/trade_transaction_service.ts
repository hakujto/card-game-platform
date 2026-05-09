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
}
