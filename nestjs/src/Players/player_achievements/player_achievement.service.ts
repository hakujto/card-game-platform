import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class PlayerAchievementService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.playerAchievement.findMany();
  }

  async findOne(id: number) {
    return this.prisma.playerAchievement.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.playerAchievement.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.playerAchievement.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.playerAchievement.delete({ where: { id } });
  }

  async increment_progress(id: number, amount: number): Promise<void> {
    const entity = await this.prisma.playerAchievement.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerAchievement not found: ' + id);
    // TODO: implement increment_progress domain logic
  }
  async complete(id: number): Promise<void> {
    const entity = await this.prisma.playerAchievement.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerAchievement not found: ' + id);
    // TODO: implement complete domain logic
  }
  // triggered by @on(is_completed = true)
  async setIsCompleted(id: number, value: string): Promise<void> {
    const entity = await this.prisma.playerAchievement.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerAchievement not found: ' + id);
    await this.prisma.playerAchievement.update({ where: { id }, data: { isCompleted: value as any } });
  }
}
