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

  async rename(id: number, newName: string): Promise<void> {
    const entity = await prisma.articleTag.findUnique({ where: { id } });
    if (!entity) throw new Error('ArticleTag not found: ' + id);
    // TODO: implement rename domain logic
    throw new Error('rename not implemented');
  }

  async article_count(id: number): Promise<number> {
    const entity = await prisma.articleTag.findUnique({ where: { id } });
    if (!entity) throw new Error('ArticleTag not found: ' + id);
    // TODO: implement article_count domain logic
    throw new Error('article_count not implemented');
  }
}
