import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AwardedPrizeService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.awardedPrize.findMany();
  }

  async findOne(id: number) {
    return this.prisma.awardedPrize.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.awardedPrize.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.awardedPrize.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.awardedPrize.delete({ where: { id } });
  }

  async claim(id: number): Promise<void> {
    const entity = await this.prisma.awardedPrize.findUnique({ where: { id } });
    if (!entity) throw new Error('AwardedPrize not found: ' + id);
    // TODO: implement claim domain logic
  }
  // triggered by @on(claimed = true)
  async setClaimed(id: number, value: string): Promise<void> {
    const entity = await this.prisma.awardedPrize.findUnique({ where: { id } });
    if (!entity) throw new Error('AwardedPrize not found: ' + id);
    await this.prisma.awardedPrize.update({ where: { id }, data: { claimed: value as any } });
  }
}
