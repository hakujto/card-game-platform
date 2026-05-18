import { prisma } from '../../lib/prisma.js';

export class CardAbilityService {
  async findAll() {
    return prisma.cardAbility.findMany();
  }

  async findOne(id: number) {
    return prisma.cardAbility.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.cardAbility.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.cardAbility.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.cardAbility.delete({ where: { id } });
  }

  async is_usable_at(timing: string): Promise<boolean> {
    throw new Error('is_usable_at not implemented');
  }

  async describe(): Promise<string> {
    throw new Error('describe not implemented');
  }
}
