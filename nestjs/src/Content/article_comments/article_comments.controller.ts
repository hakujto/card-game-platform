import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { ArticleCommentService } from './article_comment.service';

function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  return r;
}

@Controller('article_comments')
export class ArticleCommentController {
  constructor(private readonly prisma: PrismaService, private readonly articleCommentService: ArticleCommentService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.articleComment.findMany();
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.body !== undefined) data.body = body.body;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.articleId !== undefined) data.articleId = body.articleId;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.parentCommentId !== undefined) data.parentCommentId = body.parentCommentId;
    try {
      const entity = await this.prisma.articleComment.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.articleComment.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Delete(':id')
  @HttpCode(204)
  async remove(@Param('id') id: string) {
    try {
      await this.prisma.articleComment.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Post('/:id/hide')
  @HttpCode(204)
  async hide(@Param('id') id: string) {
    try {
      await this.articleCommentService.hide(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/unhide')
  @HttpCode(204)
  async unhide(@Param('id') id: string) {
    try {
      await this.articleCommentService.unhide(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/is-reply')
  async is_reply(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.articleCommentService.is_reply(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
