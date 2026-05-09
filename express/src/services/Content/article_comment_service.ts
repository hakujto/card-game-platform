import { prisma } from '../../lib/prisma.js';

export class ArticleCommentService {
  async findAll() {
    return prisma.articleComment.findMany();
  }

  async findOne(id: number) {
    return prisma.articleComment.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.articleComment.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.articleComment.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.articleComment.delete({ where: { id } });
  }
}
