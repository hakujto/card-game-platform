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

  async win_rate(id: number): Promise<number> {
    const entity = await prisma.playerSeasonStats.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerSeasonStats not found: ' + id);
    // TODO: implement win_rate domain logic
    return undefined as any;
  }

  async add_points(id: number, points: number): Promise<void> {
    const entity = await prisma.playerSeasonStats.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerSeasonStats not found: ' + id);
    // TODO: implement add_points domain logic
  }

  async record_tournament_win(id: number): Promise<void> {
    const entity = await prisma.playerSeasonStats.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerSeasonStats not found: ' + id);
    // TODO: implement record_tournament_win domain logic
  }
}
