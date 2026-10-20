import { BadRequestException, Body, ConflictException, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { ArticleService } from './article.service';


function validate(data: any): void {
  if (!((data.viewCount == null || data.viewCount >= 0))) throw new Error(`Article view count must not be negative`);
  if (!((data.likesCount == null || data.likesCount >= 0))) throw new Error(`Article likes count must not be negative`);
  if ((data.status === 'PUBLISHED') && !((data.publishedAt === undefined || data.publishedAt != null))) throw new Error(`Published article must have a published_at timestamp`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('updatedAt' in r) { r.updatedAt = r.updatedAt; delete r.updatedAt; }
  if ('publishedAt' in r) { r.publishedAt = r.publishedAt; delete r.publishedAt; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Draft': ['Published'],
  'Published': ['Archived'],
  'Archived': ['Draft']
};
function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

@Controller('articles')
export class ArticleController {
  constructor(private readonly prisma: PrismaService, private readonly articleService: ArticleService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ title: { contains: q } }, { excerpt: { contains: q } }] } : undefined;
    const items = await this.prisma.article.findMany(where ? { where } : undefined);
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.slug !== undefined) data.slug = body.slug;
    if (body.body !== undefined) data.body = body.body;
    if (body.excerpt !== undefined) data.excerpt = body.excerpt;
    if (body.coverImageUrl !== undefined) data.coverImageUrl = body.coverImageUrl;
    if (body.status !== undefined) data.status = body.status;
    if (body.articleType !== undefined) data.articleType = body.articleType;
    if (body.language !== undefined) data.language = body.language;
    if (body.viewCount !== undefined) data.viewCount = body.viewCount;
    if (body.likesCount !== undefined) data.likesCount = body.likesCount;
    if (body.totalViewsAlltime !== undefined) data.totalViewsAlltime = body.totalViewsAlltime;
    if (body.isFeatured !== undefined) data.isFeatured = body.isFeatured;
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
    try {
    validate(data);
      const entity = await this.prisma.article.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.article.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.slug !== undefined) data.slug = body.slug;
    if (body.body !== undefined) data.body = body.body;
    if (body.excerpt !== undefined) data.excerpt = body.excerpt;
    if (body.coverImageUrl !== undefined) data.coverImageUrl = body.coverImageUrl;
    if (body.articleType !== undefined) data.articleType = body.articleType;
    if (body.language !== undefined) data.language = body.language;
    if (body.totalViewsAlltime !== undefined) data.totalViewsAlltime = body.totalViewsAlltime;
    if (body.isFeatured !== undefined) data.isFeatured = body.isFeatured;
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
    try {
    validate(data);
      const existing = await this.prisma.article.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.article.update({ where: { id: Number(id) }, data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.slug !== undefined) data.slug = body.slug;
    if (body.body !== undefined) data.body = body.body;
    if (body.excerpt !== undefined) data.excerpt = body.excerpt;
    if (body.coverImageUrl !== undefined) data.coverImageUrl = body.coverImageUrl;
    if (body.articleType !== undefined) data.articleType = body.articleType;
    if (body.language !== undefined) data.language = body.language;
    if (body.totalViewsAlltime !== undefined) data.totalViewsAlltime = body.totalViewsAlltime;
    if (body.isFeatured !== undefined) data.isFeatured = body.isFeatured;
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
    try {
    validate(data);
      const existing = await this.prisma.article.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.article.update({ where: { id: Number(id) }, data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Post('/:id/publish')
  @HttpCode(204)
  async publish(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['editor', 'admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for publish');
    try {
      await this.articleService.publish(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/archive')
  @HttpCode(204)
  async archive(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['editor', 'admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for archive');
    try {
      await this.articleService.archive(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Put('/:id')
  async replace(@Param('id') id: string, @Body() body: any, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['editor', 'admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for replace');
    let result: any;
    try {
      result = await this.articleService.replace(Number(id), body.data);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/view')
  @HttpCode(204)
  async increment_view(@Param('id') id: string) {
    try {
      await this.articleService.increment_view(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/like')
  @HttpCode(204)
  async like(@Param('id') id: string) {
    try {
      await this.articleService.like(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Delete('/:id/like')
  @HttpCode(204)
  async unlike(@Param('id') id: string) {
    try {
      await this.articleService.unlike(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/reading-time')
  async reading_time_minutes(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.articleService.reading_time_minutes(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }


  @Patch(':id/transitions/draft-to-published')
  async transitionDraftToPublished(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Editor', 'Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Draft -> Published');
    const entity = await this.prisma.article.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Published');
      if ((entity as any).title == null) throw new Error('title is required for Draft -> Published');
      if ((entity as any).body == null) throw new Error('body is required for Draft -> Published');
      return await this.prisma.article.update({ where: { id: Number(id) }, data: { status: 'Published' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/published-to-archived')
  async transitionPublishedToArchived(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Editor', 'Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Published -> Archived');
    const entity = await this.prisma.article.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Archived');
      return await this.prisma.article.update({ where: { id: Number(id) }, data: { status: 'Archived' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/archived-to-draft')
  async transitionArchivedToDraft(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Archived -> Draft');
    const entity = await this.prisma.article.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Draft');
      return await this.prisma.article.update({ where: { id: Number(id) }, data: { status: 'Draft' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/published-to-draft')
  async transitionPublishedToDraft(@Param('id') id: string) {
    throw new ConflictException('Transition Published -> Draft is not allowed');
  }
}
