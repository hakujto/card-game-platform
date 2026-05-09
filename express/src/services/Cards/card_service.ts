import { prisma } from '../../lib/prisma.js';

export class CardService {
  async findAll() {
    return prisma.card.findMany();
  }

  async findOne(id: number) {
    return prisma.card.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.card.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.card.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.card.delete({ where: { id } });
  }
}
