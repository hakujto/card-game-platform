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

  async start(id: number): Promise<void> {
    const entity = await prisma.tournamentRound.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentRound not found: ' + id);
    // TODO: implement start domain logic
  }

  async complete(id: number): Promise<void> {
    const entity = await prisma.tournamentRound.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentRound not found: ' + id);
    // TODO: implement complete domain logic
  }

  async generate_pairings(id: number): Promise<void> {
    const entity = await prisma.tournamentRound.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentRound not found: ' + id);
    // TODO: implement generate_pairings domain logic
  }

  async is_time_expired(id: number): Promise<boolean> {
    const entity = await prisma.tournamentRound.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentRound not found: ' + id);
    // TODO: implement is_time_expired domain logic
    return undefined as any;
  }
}
