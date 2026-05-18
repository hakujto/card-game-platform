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

  async is_reply(): Promise<boolean> {
    throw new Error('is_reply not implemented');
  }
  async hide(id: number): Promise<void> {
    const entity = await prisma.articleComment.findUnique({ where: { id } });
    if (!entity) throw new Error('ArticleComment not found: ' + id);
    // TODO: implement hide domain logic
    throw new Error('hide not implemented');
  }

  async unhide(id: number): Promise<void> {
    const entity = await prisma.articleComment.findUnique({ where: { id } });
    if (!entity) throw new Error('ArticleComment not found: ' + id);
    // TODO: implement unhide domain logic
    throw new Error('unhide not implemented');
  }
}
