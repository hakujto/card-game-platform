import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AchievementService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.achievement.findMany();
  }

  async findOne(id: number) {
    return this.prisma.achievement.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.achievement.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.achievement.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.achievement.delete({ where: { id } });
  }

  async point_value(id: number, multiplier: number): Promise<number> {
    const entity = await this.prisma.achievement.findUnique({ where: { id } });
    if (!entity) throw new Error('Achievement not found: ' + id);
    // TODO: implement point_value domain logic
    return undefined as any;
  }
  async reveal(id: number): Promise<void> {
    const entity = await this.prisma.achievement.findUnique({ where: { id } });
    if (!entity) throw new Error('Achievement not found: ' + id);
    // TODO: implement reveal domain logic
  }
}
