import { prisma } from '../../lib/prisma.js';

export class GameService {
  async findAll() {
    return prisma.game.findMany();
  }

  async findOne(id: number) {
    return prisma.game.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.game.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.game.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.game.delete({ where: { id } });
  }
}
