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

  async is_usable_at(id: number, timing: string): Promise<boolean> {
    const entity = await prisma.cardAbility.findUnique({ where: { id } });
    if (!entity) throw new Error('CardAbility not found: ' + id);
    // TODO: implement is_usable_at domain logic
    throw new Error('is_usable_at not implemented');
  }

  async describe(id: number): Promise<string> {
    const entity = await prisma.cardAbility.findUnique({ where: { id } });
    if (!entity) throw new Error('CardAbility not found: ' + id);
    // TODO: implement describe domain logic
    throw new Error('describe not implemented');
  }
}
