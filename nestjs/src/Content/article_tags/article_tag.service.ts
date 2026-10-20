import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class ArticleTagService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.articleTag.findMany();
  }

  async findOne(id: number) {
    return this.prisma.articleTag.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.articleTag.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.articleTag.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.articleTag.delete({ where: { id } });
  }

  async rename(id: number, newName: string): Promise<void> {
    const entity = await this.prisma.articleTag.findUnique({ where: { id } });
    if (!entity) throw new Error('ArticleTag not found: ' + id);
    // TODO: implement rename domain logic
  }
  async article_count(id: number): Promise<number> {
    const entity = await this.prisma.articleTag.findUnique({ where: { id } });
    if (!entity) throw new Error('ArticleTag not found: ' + id);
    // TODO: implement article_count domain logic
    return undefined as any;
  }
}
