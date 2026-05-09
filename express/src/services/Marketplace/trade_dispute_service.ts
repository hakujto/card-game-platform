import { prisma } from '../../lib/prisma.js';

export class TradeDisputeService {
  async findAll() {
    return prisma.tradeDispute.findMany();
  }

  async findOne(id: number) {
    return prisma.tradeDispute.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tradeDispute.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tradeDispute.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tradeDispute.delete({ where: { id } });
  }
}
