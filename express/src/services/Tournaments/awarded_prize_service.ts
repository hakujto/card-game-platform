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

}
