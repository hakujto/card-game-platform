import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { DeckSideboardCardService } from './deck_sideboard_card.service';


function validate(data: any): void {
  if (!((data.quantity == null || (data.quantity >= 1 && data.quantity <= 4)))) throw new Error(`Sideboard card quantity must be between 1 and 4 copies`);
}

@Controller('deck_sideboard_cards')
export class DeckSideboardCardController {
  constructor(private readonly prisma: PrismaService, private readonly deckSideboardCardService: DeckSideboardCardService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.deckSideboardCard.findMany();
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.deckId !== undefined) data.deckId = body.deckId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
    validate(data);
      const entity = await this.prisma.deckSideboardCard.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.deckSideboardCard.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.deckId !== undefined) data.deckId = body.deckId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
    validate(data);
      const existing = await this.prisma.deckSideboardCard.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.deckSideboardCard.update({ where: { id: Number(id) }, data });
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
      await this.prisma.deckSideboardCard.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Patch('/:id/increment')
  @HttpCode(204)
  async increment(@Param('id') id: string, @Body() body: any) {
    try {
      await this.deckSideboardCardService.increment(Number(id), body.amount);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch('/:id/decrement')
  @HttpCode(204)
  async decrement(@Param('id') id: string, @Body() body: any) {
    try {
      await this.deckSideboardCardService.decrement(Number(id), body.amount);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
