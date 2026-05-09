import { prisma } from '../../lib/prisma.js';

export class TournamentRoundService {
  async findAll() {
    return prisma.tournamentRound.findMany();
  }

  async findOne(id: number) {
    return prisma.tournamentRound.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tournamentRound.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tournamentRound.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tournamentRound.delete({ where: { id } });
  }
}
