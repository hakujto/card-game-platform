import { prisma } from '../../lib/prisma.js';

export class DeckTagAssignmentService {
  async findAll() {
    return prisma.deckTagAssignment.findMany();
  }

  async findOne(id: number) {
    return prisma.deckTagAssignment.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.deckTagAssignment.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.deckTagAssignment.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.deckTagAssignment.delete({ where: { id } });
  }

}
