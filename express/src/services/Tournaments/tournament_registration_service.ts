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

  async withdraw(id: number): Promise<void> {
    const entity = await prisma.tournamentRegistration.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentRegistration not found: ' + id);
    // TODO: implement withdraw domain logic
    throw new Error('withdraw not implemented');
  }

  async disqualify(id: number, reason: string): Promise<void> {
    const entity = await prisma.tournamentRegistration.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentRegistration not found: ' + id);
    // TODO: implement disqualify domain logic
    throw new Error('disqualify not implemented');
  }

  async promote_from_waitlist(id: number): Promise<void> {
    const entity = await prisma.tournamentRegistration.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentRegistration not found: ' + id);
    // TODO: implement promote_from_waitlist domain logic
    throw new Error('promote_from_waitlist not implemented');
  }
}
