import { prisma } from '../../lib/prisma.js';

export class ArticleTagService {
  async findAll() {
    return prisma.articleTag.findMany();
  }

  async findOne(id: number) {
    return prisma.articleTag.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.articleTag.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.articleTag.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.articleTag.delete({ where: { id } });
  }

  async rename(newName: string): Promise<void> {
    throw new Error('rename not implemented');
  }

  async article_count(): Promise<number> {
    throw new Error('article_count not implemented');
  }
}
