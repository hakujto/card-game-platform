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

}
