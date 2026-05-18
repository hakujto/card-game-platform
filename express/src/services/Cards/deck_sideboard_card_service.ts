import { prisma } from '../../lib/prisma.js';

export class DeckSideboardCardService {
  async findAll() {
    return prisma.deckSideboardCard.findMany();
  }

  async findOne(id: number) {
    return prisma.deckSideboardCard.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.deckSideboardCard.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.deckSideboardCard.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.deckSideboardCard.delete({ where: { id } });
  }

  async increment(amount: number): Promise<void> {
    throw new Error('increment not implemented');
  }

  async decrement(amount: number): Promise<void> {
    throw new Error('decrement not implemented');
  }
}
