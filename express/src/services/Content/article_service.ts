import { prisma } from '../../lib/prisma.js';

export class ArticleService {
  async findAll() {
    return prisma.article.findMany();
  }

  async findOne(id: number) {
    return prisma.article.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.article.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.article.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.article.delete({ where: { id } });
  }
}
