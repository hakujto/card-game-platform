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

  async promote_to_head(id: number): Promise<void> {
    const entity = await prisma.tournamentJudge.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentJudge not found: ' + id);
    // TODO: implement promote_to_head domain logic
    throw new Error('promote_to_head not implemented');
  }
}
