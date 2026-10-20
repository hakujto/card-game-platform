import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class ArticleCommentService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.articleComment.findMany();
  }

  async findOne(id: number) {
    return this.prisma.articleComment.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.articleComment.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.articleComment.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.articleComment.delete({ where: { id } });
  }

  async hide(id: number): Promise<void> {
    const entity = await this.prisma.articleComment.findUnique({ where: { id } });
    if (!entity) throw new Error('ArticleComment not found: ' + id);
    // TODO: implement hide domain logic
  }
  async unhide(id: number): Promise<void> {
    const entity = await this.prisma.articleComment.findUnique({ where: { id } });
    if (!entity) throw new Error('ArticleComment not found: ' + id);
    // TODO: implement unhide domain logic
  }
  async is_reply(id: number): Promise<boolean> {
    const entity = await this.prisma.articleComment.findUnique({ where: { id } });
    if (!entity) throw new Error('ArticleComment not found: ' + id);
    // TODO: implement is_reply domain logic
    return undefined as any;
  }
}
