import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { PlayerCollectionService } from './player_collection.service';


function validate(data: any): void {
  if (!((data.quantity == null || data.quantity > 0))) throw new Error(`Collection quantity must be greater than zero`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('acquiredAt' in r) { r.acquiredAt = r.acquiredAt; delete r.acquiredAt; }
  return r;
}

@Controller('player_collections')
export class PlayerCollectionController {
  constructor(private readonly prisma: PrismaService, private readonly playerCollectionService: PlayerCollectionService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.playerCollection.findMany();
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.acquiredAt !== undefined) data.acquiredAt = body.acquiredAt != null ? new Date(body.acquiredAt) : null;
    if (body.acquiredVia !== undefined) data.acquiredVia = body.acquiredVia;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
    validate(data);
      const entity = await this.prisma.playerCollection.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string, @Req() request: any) {
    const entity = await this.prisma.playerCollection.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    if (entity.playerId !== (request as any).userId) throw new ForbiddenException('You do not own this resource.');
    return applyProjection(entity);
  }

  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() body: any, @Req() request: any) {
    const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.acquiredAt !== undefined) data.acquiredAt = body.acquiredAt != null ? new Date(body.acquiredAt) : null;
    if (body.acquiredVia !== undefined) data.acquiredVia = body.acquiredVia;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
    validate(data);
      const existing = await this.prisma.playerCollection.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
    if (existing.playerId !== (request as any).userId) throw new ForbiddenException('You do not own this resource.');
      const entity = await this.prisma.playerCollection.update({ where: { id: Number(id) }, data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Delete(':id')
  @HttpCode(204)
  async remove(@Param('id') id: string, @Req() request: any) {
    try {
      const existing = await this.prisma.playerCollection.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
    if (existing.playerId !== (request as any).userId) throw new ForbiddenException('You do not own this resource.');
      await this.prisma.playerCollection.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Post('/:id/add')
  @HttpCode(204)
  async add(@Param('id') id: string, @Body() body: any) {
    try {
      await this.playerCollectionService.add(Number(id), body.quantity);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/value')
  async estimated_value(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.playerCollectionService.estimated_value(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
