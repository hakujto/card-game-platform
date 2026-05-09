import { prisma } from '../../lib/prisma.js';

export class TournamentPrizeService {
  async findAll() {
    return prisma.tournamentPrize.findMany();
  }

  async findOne(id: number) {
    return prisma.tournamentPrize.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tournamentPrize.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tournamentPrize.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tournamentPrize.delete({ where: { id } });
  }
}
