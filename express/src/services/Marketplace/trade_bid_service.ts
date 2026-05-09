import { prisma } from '../../lib/prisma.js';

export class TradeBidService {
  async findAll() {
    return prisma.tradeBid.findMany();
  }

  async findOne(id: number) {
    return prisma.tradeBid.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tradeBid.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tradeBid.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tradeBid.delete({ where: { id } });
  }
}
