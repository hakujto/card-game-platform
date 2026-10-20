import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class TournamentRegistrationService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.tournamentRegistration.findMany();
  }

  async findOne(id: number) {
    return this.prisma.tournamentRegistration.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.tournamentRegistration.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.tournamentRegistration.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.tournamentRegistration.delete({ where: { id } });
  }

  async withdraw(id: number): Promise<void> {
    const entity = await this.prisma.tournamentRegistration.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentRegistration not found: ' + id);
    // TODO: implement withdraw domain logic
  }
  async disqualify(id: number, reason: string): Promise<void> {
    const entity = await this.prisma.tournamentRegistration.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentRegistration not found: ' + id);
    // TODO: implement disqualify domain logic
  }
  async promote_from_waitlist(id: number): Promise<void> {
    const entity = await this.prisma.tournamentRegistration.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentRegistration not found: ' + id);
    // TODO: implement promote_from_waitlist domain logic
  }
}
