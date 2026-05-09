import { prisma } from '../../lib/prisma.js';

export class TradelistingService {
  async findAll() {
    return prisma.tradelisting.findMany();
  }

  async findOne(id: number) {
    return prisma.tradelisting.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tradelisting.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tradelisting.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tradelisting.delete({ where: { id } });
  }
}
