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

  async increment(id: number, amount: number): Promise<void> {
    const entity = await prisma.deckSideboardCard.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckSideboardCard not found: ' + id);
    // TODO: implement increment domain logic
    throw new Error('increment not implemented');
  }

  async decrement(id: number, amount: number): Promise<void> {
    const entity = await prisma.deckSideboardCard.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckSideboardCard not found: ' + id);
    // TODO: implement decrement domain logic
    throw new Error('decrement not implemented');
  }
}
