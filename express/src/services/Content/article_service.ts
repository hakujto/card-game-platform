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

  async publish(id: number): Promise<void> {
    const entity = await prisma.article.findUnique({ where: { id } });
    if (!entity) throw new Error('Article not found: ' + id);
    // TODO: implement publish domain logic
  }

  async archive(id: number): Promise<void> {
    const entity = await prisma.article.findUnique({ where: { id } });
    if (!entity) throw new Error('Article not found: ' + id);
    // TODO: implement archive domain logic
  }

  async increment_view(id: number): Promise<void> {
    const entity = await prisma.article.findUnique({ where: { id } });
    if (!entity) throw new Error('Article not found: ' + id);
    // TODO: implement increment_view domain logic
  }

  async like(id: number): Promise<void> {
    const entity = await prisma.article.findUnique({ where: { id } });
    if (!entity) throw new Error('Article not found: ' + id);
    // TODO: implement like domain logic
  }

  async unlike(id: number): Promise<void> {
    const entity = await prisma.article.findUnique({ where: { id } });
    if (!entity) throw new Error('Article not found: ' + id);
    // TODO: implement unlike domain logic
  }

  async reading_time_minutes(id: number): Promise<number> {
    const entity = await prisma.article.findUnique({ where: { id } });
    if (!entity) throw new Error('Article not found: ' + id);
    // TODO: implement reading_time_minutes domain logic
    return undefined as any;
  }
  // ── Lifecycle hooks ──────────────────────────────────────────────

  async updateSearchIndex(entity: any): Promise<void> {
    // TODO: implement update_search_index
  }
}
