import { prisma } from '../../lib/prisma.js';

export class TournamentJudgeService {
  async findAll() {
    return prisma.tournamentJudge.findMany();
  }

  async findOne(id: number) {
    return prisma.tournamentJudge.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tournamentJudge.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tournamentJudge.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tournamentJudge.delete({ where: { id } });
  }

}
