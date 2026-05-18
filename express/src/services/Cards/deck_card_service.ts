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

  async increment(id: number, amount: number): Promise<void> {
    const entity = await prisma.deckCard.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckCard not found: ' + id);
    // TODO: implement increment domain logic
    throw new Error('increment not implemented');
  }

  async decrement(id: number, amount: number): Promise<void> {
    const entity = await prisma.deckCard.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckCard not found: ' + id);
    // TODO: implement decrement domain logic
    throw new Error('decrement not implemented');
  }
}
