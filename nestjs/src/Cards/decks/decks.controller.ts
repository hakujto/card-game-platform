import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { DeckService } from './deck.service';


function validate(data: any): void {
  if (!((data.wins == null || data.wins >= 0))) throw new Error(`Deck wins count must not be negative`);
  if (!((data.losses == null || data.losses >= 0))) throw new Error(`Deck losses count must not be negative`);
  if (!((data.draws == null || data.draws >= 0))) throw new Error(`Deck draws count must not be negative`);
  if ((data.isTournamentLegal === true) && !(data.isPublic === true)) throw new Error(`Tournament-legal deck must be made public`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('updatedAt' in r) { r.updatedAt = r.updatedAt; delete r.updatedAt; }
  return r;
}

@Controller('decks')
export class DeckController {
  constructor(private readonly prisma: PrismaService, private readonly deckService: DeckService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ name: { contains: q } }, { description: { contains: q } }] } : undefined;
    const items = await this.prisma.deck.findMany(where ? { where } : undefined);
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.isPublic !== undefined) data.isPublic = body.isPublic;
    if (body.isTournamentLegal !== undefined) data.isTournamentLegal = body.isTournamentLegal;
    if (body.archetype !== undefined) data.archetype = body.archetype;
    if (body.wins !== undefined) data.wins = body.wins;
    if (body.losses !== undefined) data.losses = body.losses;
    if (body.draws !== undefined) data.draws = body.draws;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    try {
    validate(data);
      const entity = await this.prisma.deck.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.deck.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.isPublic !== undefined) data.isPublic = body.isPublic;
    if (body.isTournamentLegal !== undefined) data.isTournamentLegal = body.isTournamentLegal;
    if (body.archetype !== undefined) data.archetype = body.archetype;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    try {
    validate(data);
      const existing = await this.prisma.deck.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.deck.update({ where: { id: Number(id) }, data });
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
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.isPublic !== undefined) data.isPublic = body.isPublic;
    if (body.isTournamentLegal !== undefined) data.isTournamentLegal = body.isTournamentLegal;
    if (body.archetype !== undefined) data.archetype = body.archetype;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    try {
    validate(data);
      const existing = await this.prisma.deck.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.deck.update({ where: { id: Number(id) }, data });
      return applyProjection(entity);
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
      await this.prisma.deck.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Get('/:id/validate')
  async validate_size(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.deckService.validate_size(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/cards')
  @HttpCode(204)
  async add_card(@Param('id') id: string, @Body() body: any) {
    try {
      await this.deckService.add_card(Number(id), body.cardId, body.quantity);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Delete('/:id/cards/:card_id')
  @HttpCode(204)
  async remove_card(@Param('id') id: string, @Param('card_id') cardId: string) {
    try {
      await this.deckService.remove_card(Number(id), Number(cardId));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/win-rate')
  async win_rate(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.deckService.win_rate(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/clone')
  async clone(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.deckService.clone(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/publish')
  @HttpCode(204)
  async publish(@Param('id') id: string) {
    try {
      await this.deckService.publish(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/unpublish')
  @HttpCode(204)
  async unpublish(@Param('id') id: string) {
    try {
      await this.deckService.unpublish(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/certify')
  async certify_tournament_legal(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.deckService.certify_tournament_legal(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
