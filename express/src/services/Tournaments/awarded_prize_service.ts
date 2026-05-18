import { prisma } from '../../lib/prisma.js';

export class AwardedPrizeService {
  async findAll() {
    return prisma.awardedPrize.findMany();
  }

  async findOne(id: number) {
    return prisma.awardedPrize.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.awardedPrize.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.awardedPrize.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.awardedPrize.delete({ where: { id } });
  }

  async claim(id: number): Promise<void> {
    const entity = await prisma.awardedPrize.findUnique({ where: { id } });
    if (!entity) throw new Error('AwardedPrize not found: ' + id);
    // TODO: implement claim domain logic
    throw new Error('claim not implemented');
  }

  // triggered by @on(claimed = true)
  async setClaimed(id: number, value: string): Promise<void> {
    const entity = await prisma.awardedPrize.findUnique({ where: { id } });
    if (!entity) throw new Error('AwardedPrize not found: ' + id);
    await prisma.awardedPrize.update({ where: { id }, data: { claimed: value as any } });
    if (value === 'TRUE') {
      // TODO: call entity.claim() after implementing domain model
    }
  }
}
