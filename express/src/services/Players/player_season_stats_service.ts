import { prisma } from '../../lib/prisma.js';

export class PlayerSeasonStatsService {
  async findAll() {
    return prisma.playerSeasonStats.findMany();
  }

  async findOne(id: number) {
    return prisma.playerSeasonStats.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.playerSeasonStats.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.playerSeasonStats.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.playerSeasonStats.delete({ where: { id } });
  }
}
