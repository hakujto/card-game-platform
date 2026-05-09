import { prisma } from '../../lib/prisma.js';

export class DeckTagService {
  async findAll() {
    return prisma.deckTag.findMany();
  }

  async findOne(id: number) {
    return prisma.deckTag.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.deckTag.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.deckTag.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.deckTag.delete({ where: { id } });
  }
}
