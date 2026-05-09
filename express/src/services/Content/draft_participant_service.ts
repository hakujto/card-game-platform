import { prisma } from '../../lib/prisma.js';

export class DraftParticipantService {
  async findAll() {
    return prisma.draftParticipant.findMany();
  }

  async findOne(id: number) {
    return prisma.draftParticipant.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.draftParticipant.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.draftParticipant.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.draftParticipant.delete({ where: { id } });
  }
}
