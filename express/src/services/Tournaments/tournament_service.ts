import { prisma } from '../../lib/prisma.js';

export class TournamentService {
  async findAll() {
    return prisma.tournament.findMany();
  }

  async findOne(id: number) {
    return prisma.tournament.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tournament.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tournament.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tournament.delete({ where: { id } });
  }
}
