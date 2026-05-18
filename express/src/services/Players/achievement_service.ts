import { prisma } from '../../lib/prisma.js';

export class AchievementService {
  async findAll() {
    return prisma.achievement.findMany();
  }

  async findOne(id: number) {
    return prisma.achievement.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.achievement.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.achievement.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.achievement.delete({ where: { id } });
  }

  async point_value(id: number, multiplier: number): Promise<number> {
    const entity = await prisma.achievement.findUnique({ where: { id } });
    if (!entity) throw new Error('Achievement not found: ' + id);
    // TODO: implement point_value domain logic
    throw new Error('point_value not implemented');
  }

  async reveal(id: number): Promise<void> {
    const entity = await prisma.achievement.findUnique({ where: { id } });
    if (!entity) throw new Error('Achievement not found: ' + id);
    // TODO: implement reveal domain logic
    throw new Error('reveal not implemented');
  }
}
