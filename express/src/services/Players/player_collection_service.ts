import { prisma } from '../../lib/prisma.js';

export class PlayerCollectionService {
  async findAll() {
    return prisma.playerCollection.findMany();
  }

  async findOne(id: number) {
    return prisma.playerCollection.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.playerCollection.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.playerCollection.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.playerCollection.delete({ where: { id } });
  }

  async add(quantity: number): Promise<void> {
    throw new Error('add not implemented');
  }
  async estimated_value(id: number): Promise<number> {
    const entity = await prisma.playerCollection.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerCollection not found: ' + id);
    // TODO: implement estimated_value domain logic
    throw new Error('estimated_value not implemented');
  }
}
