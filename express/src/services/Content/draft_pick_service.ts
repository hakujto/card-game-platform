import { prisma } from '../../lib/prisma.js';

export class DraftPickService {
  async findAll() {
    return prisma.draftPick.findMany();
  }

  async findOne(id: number) {
    return prisma.draftPick.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.draftPick.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.draftPick.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.draftPick.delete({ where: { id } });
  }
}
