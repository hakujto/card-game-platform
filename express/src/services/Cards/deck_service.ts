import { prisma } from '../../lib/prisma.js';

export class DeckService {
  async findAll() {
    return prisma.deck.findMany();
  }

  async findOne(id: number) {
    return prisma.deck.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.deck.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.deck.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.deck.delete({ where: { id } });
  }
}
