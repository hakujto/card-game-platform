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

}
