import { prisma } from '../../lib/prisma.js';

export class SeasonService {
  async findAll() {
    return prisma.season.findMany();
  }

  async findOne(id: number) {
    return prisma.season.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.season.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.season.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.season.delete({ where: { id } });
  }
}
