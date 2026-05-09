import { prisma } from '../../lib/prisma.js';

export class PlayerService {
  async findAll() {
    return prisma.player.findMany();
  }

  async findOne(id: number) {
    return prisma.player.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.player.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.player.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.player.delete({ where: { id } });
  }
}
