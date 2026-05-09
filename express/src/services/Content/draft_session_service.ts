import { prisma } from '../../lib/prisma.js';

export class DraftSessionService {
  async findAll() {
    return prisma.draftSession.findMany();
  }

  async findOne(id: number) {
    return prisma.draftSession.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.draftSession.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.draftSession.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.draftSession.delete({ where: { id } });
  }
}
