import { prisma } from '../../lib/prisma.js';

export class CardRulingService {
  async findAll() {
    return prisma.cardRuling.findMany();
  }

  async findOne(id: number) {
    return prisma.cardRuling.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.cardRuling.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.cardRuling.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.cardRuling.delete({ where: { id } });
  }

  async is_current(): Promise<boolean> {
    throw new Error('is_current not implemented');
  }

  async supersedes_previous(): Promise<boolean> {
    throw new Error('supersedes_previous not implemented');
  }
}
