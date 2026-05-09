import { prisma } from '../../lib/prisma.js';

export class MatchService {
  async findAll() {
    return prisma.match.findMany();
  }

  async findOne(id: number) {
    return prisma.match.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.match.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.match.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.match.delete({ where: { id } });
  }
}
