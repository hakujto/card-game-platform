import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { ArticleTagService } from './article_tag.service';


@Controller('article_tags')
export class ArticleTagController {
  constructor(private readonly prisma: PrismaService, private readonly articleTagService: ArticleTagService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ name: { contains: q } }] } : undefined;
    const items = await this.prisma.articleTag.findMany(where ? { where } : undefined);
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.slug !== undefined) data.slug = body.slug;
    try {
      const entity = await this.prisma.articleTag.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.articleTag.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.slug !== undefined) data.slug = body.slug;
    try {
      const existing = await this.prisma.articleTag.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.articleTag.update({ where: { id: Number(id) }, data });
      return entity;
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Delete(':id')
  @HttpCode(204)
  async remove(@Param('id') id: string) {
    try {
      await this.prisma.articleTag.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Patch('/:id/rename')
  @HttpCode(204)
  async rename(@Param('id') id: string, @Body() body: any) {
    try {
      await this.articleTagService.rename(Number(id), body.newName);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/article-count')
  async article_count(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.articleTagService.article_count(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
