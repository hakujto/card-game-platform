import { prisma } from '../../lib/prisma.js';

export class MatchService {
  async findAll() {
    return prisma.match.findMany();
  }

  async findOne(id: number) {
    return prisma.match.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.match.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.match.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.match.delete({ where: { id } });
  }

  async record_result(id: number, p1Wins: number, p2Wins: number): Promise<void> {
    const entity = await prisma.match.findUnique({ where: { id } });
    if (!entity) throw new Error('Match not found: ' + id);
    // TODO: implement record_result domain logic
    throw new Error('record_result not implemented');
  }

  async determine_winner(id: number): Promise<boolean> {
    const entity = await prisma.match.findUnique({ where: { id } });
    if (!entity) throw new Error('Match not found: ' + id);
    // TODO: implement determine_winner domain logic
    throw new Error('determine_winner not implemented');
  }

  async draw(id: number): Promise<void> {
    const entity = await prisma.match.findUnique({ where: { id } });
    if (!entity) throw new Error('Match not found: ' + id);
    // TODO: implement draw domain logic
    throw new Error('draw not implemented');
  }
}
