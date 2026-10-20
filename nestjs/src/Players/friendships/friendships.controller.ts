import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Post, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FriendshipService } from './friendship.service';

function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  return r;
}

@Controller('friendships')
export class FriendshipController {
  constructor(private readonly prisma: PrismaService, private readonly friendshipService: FriendshipService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.friendship.findMany();
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.requesterId !== undefined) data.requesterId = body.requesterId;
    if (body.receiverId !== undefined) data.receiverId = body.receiverId;
    try {
      const entity = await this.prisma.friendship.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string, @Req() request: any) {
    const entity = await this.prisma.friendship.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    if (entity.requesterId !== (request as any).userId) throw new ForbiddenException('You do not own this resource.');
    return applyProjection(entity);
  }

  @Delete(':id')
  @HttpCode(204)
  async remove(@Param('id') id: string, @Req() request: any) {
    try {
      const existing = await this.prisma.friendship.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
    if (existing.requesterId !== (request as any).userId) throw new ForbiddenException('You do not own this resource.');
      await this.prisma.friendship.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Post('/:id/accept')
  @HttpCode(204)
  async accept(@Param('id') id: string) {
    try {
      await this.friendshipService.accept(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/decline')
  @HttpCode(204)
  async decline(@Param('id') id: string) {
    try {
      await this.friendshipService.decline(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/block')
  @HttpCode(204)
  async block(@Param('id') id: string) {
    try {
      await this.friendshipService.block(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
