import { prisma } from '../../lib/prisma.js';

export class ArticleTagAssignmentService {
  async findAll() {
    return prisma.articleTagAssignment.findMany();
  }

  async findOne(id: number) {
    return prisma.articleTagAssignment.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.articleTagAssignment.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.articleTagAssignment.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.articleTagAssignment.delete({ where: { id } });
  }
}
