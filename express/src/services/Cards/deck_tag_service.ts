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

  async rename(id: number, newName: string): Promise<void> {
    const entity = await prisma.deckTag.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckTag not found: ' + id);
    // TODO: implement rename domain logic
    throw new Error('rename not implemented');
  }

  async merge_into(id: number, targetTagId: number): Promise<void> {
    const entity = await prisma.deckTag.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckTag not found: ' + id);
    // TODO: implement merge_into domain logic
    throw new Error('merge_into not implemented');
  }
}
