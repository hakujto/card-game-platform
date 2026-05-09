import { prisma } from '../../lib/prisma.js';

export class DeckCardService {
  async findAll() {
    return prisma.deckCard.findMany();
  }

  async findOne(id: number) {
    return prisma.deckCard.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.deckCard.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.deckCard.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.deckCard.delete({ where: { id } });
  }
}
