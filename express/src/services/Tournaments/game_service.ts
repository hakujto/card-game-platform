import { prisma } from '../../lib/prisma.js';

export class GameService {
  async findAll() {
    return prisma.game.findMany();
  }

  async findOne(id: number) {
    return prisma.game.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.game.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.game.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.game.delete({ where: { id } });
  }

  async record_winner(id: number, winnerSide: string): Promise<void> {
    const entity = await prisma.game.findUnique({ where: { id } });
    if (!entity) throw new Error('Game not found: ' + id);
    // TODO: implement record_winner domain logic
    throw new Error('record_winner not implemented');
  }

  async duration_minutes(id: number): Promise<number> {
    const entity = await prisma.game.findUnique({ where: { id } });
    if (!entity) throw new Error('Game not found: ' + id);
    // TODO: implement duration_minutes domain logic
    throw new Error('duration_minutes not implemented');
  }
}
