import { prisma } from '../../lib/prisma.js';

export class PlayerAchievementService {
  async findAll() {
    return prisma.playerAchievement.findMany();
  }

  async findOne(id: number) {
    return prisma.playerAchievement.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.playerAchievement.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.playerAchievement.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.playerAchievement.delete({ where: { id } });
  }

  async increment_progress(id: number, amount: number): Promise<void> {
    const entity = await prisma.playerAchievement.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerAchievement not found: ' + id);
    // TODO: implement increment_progress domain logic
    throw new Error('increment_progress not implemented');
  }

  async complete(id: number): Promise<void> {
    const entity = await prisma.playerAchievement.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerAchievement not found: ' + id);
    // TODO: implement complete domain logic
    throw new Error('complete not implemented');
  }

  // triggered by @on(is_completed = true)
  async setIsCompleted(id: number, value: string): Promise<void> {
    const entity = await prisma.playerAchievement.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerAchievement not found: ' + id);
    await prisma.playerAchievement.update({ where: { id }, data: { isCompleted: value as any } });
    if (value === 'TRUE') {
      // TODO: call entity.complete() after implementing domain model
    }
  }
}
