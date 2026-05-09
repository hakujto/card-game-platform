import { prisma } from '../../lib/prisma.js';

export class TournamentRegistrationService {
  async findAll() {
    return prisma.tournamentRegistration.findMany();
  }

  async findOne(id: number) {
    return prisma.tournamentRegistration.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tournamentRegistration.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tournamentRegistration.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tournamentRegistration.delete({ where: { id } });
  }
}
