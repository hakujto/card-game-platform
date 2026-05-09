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
}
