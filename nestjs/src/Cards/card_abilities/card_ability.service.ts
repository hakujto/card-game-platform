import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CardAbilityService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.cardAbility.findMany();
  }

  async findOne(id: number) {
    return this.prisma.cardAbility.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.cardAbility.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.cardAbility.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.cardAbility.delete({ where: { id } });
  }

  async is_usable_at(id: number, timing: string): Promise<boolean> {
    const entity = await this.prisma.cardAbility.findUnique({ where: { id } });
    if (!entity) throw new Error('CardAbility not found: ' + id);
    // TODO: implement is_usable_at domain logic
    return undefined as any;
  }
  async describe(id: number): Promise<string> {
    const entity = await this.prisma.cardAbility.findUnique({ where: { id } });
    if (!entity) throw new Error('CardAbility not found: ' + id);
    // TODO: implement describe domain logic
    return undefined as any;
  }
}
