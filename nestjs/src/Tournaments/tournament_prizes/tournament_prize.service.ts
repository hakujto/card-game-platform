import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class TournamentPrizeService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.tournamentPrize.findMany();
  }

  async findOne(id: number) {
    return this.prisma.tournamentPrize.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.tournamentPrize.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.tournamentPrize.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.tournamentPrize.delete({ where: { id } });
  }

  async applies_to_placement(id: number, placement: number): Promise<boolean> {
    const entity = await this.prisma.tournamentPrize.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentPrize not found: ' + id);
    // TODO: implement applies_to_placement domain logic
    return undefined as any;
  }
  async award_to_player(id: number, playerId: number): Promise<void> {
    const entity = await this.prisma.tournamentPrize.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentPrize not found: ' + id);
    // TODO: implement award_to_player domain logic
  }
}
