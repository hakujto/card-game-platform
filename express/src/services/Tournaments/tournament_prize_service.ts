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

  async applies_to_placement(id: number, placement: number): Promise<boolean> {
    const entity = await prisma.tournamentPrize.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentPrize not found: ' + id);
    // TODO: implement applies_to_placement domain logic
    throw new Error('applies_to_placement not implemented');
  }

  async award_to_player(id: number, playerId: number): Promise<void> {
    const entity = await prisma.tournamentPrize.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentPrize not found: ' + id);
    // TODO: implement award_to_player domain logic
    throw new Error('award_to_player not implemented');
  }
}
