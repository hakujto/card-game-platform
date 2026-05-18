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

  async win_rate(): Promise<number> {
    throw new Error('win_rate not implemented');
  }

  async add_points(points: number): Promise<void> {
    throw new Error('add_points not implemented');
  }

  async record_tournament_win(): Promise<void> {
    throw new Error('record_tournament_win not implemented');
  }
}
