import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { DeckCardService } from './deck_card.service';


function validate(data: any): void {
  if (data.quantity != null && Number(data.quantity) < 1) throw new Error('quantity: must be >= 1');
  if (data.quantity != null && Number(data.quantity) > 4) throw new Error('quantity: must be <= 4');
  if (!((data.quantity == null || (data.quantity >= 1 && data.quantity <= 4)))) throw new Error(`A deck can contain between 1 and 4 copies of a card`);
  if ((data.isCommander === true) && !(data.quantity === 1)) throw new Error(`Commander card must appear exactly once in the deck`);
}

@Controller('deck_cards')
export class DeckCardController {
  constructor(private readonly prisma: PrismaService, private readonly deckCardService: DeckCardService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.deckCard.findMany();
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.isCommander !== undefined) data.isCommander = body.isCommander;
    if (body.deckId !== undefined) data.deckId = body.deckId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
    validate(data);
      const entity = await this.prisma.deckCard.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.deckCard.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.isCommander !== undefined) data.isCommander = body.isCommander;
    if (body.deckId !== undefined) data.deckId = body.deckId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
    validate(data);
      const existing = await this.prisma.deckCard.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.deckCard.update({ where: { id: Number(id) }, data });
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
      await this.prisma.deckCard.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Patch('/:id/increment')
  @HttpCode(204)
  async increment(@Param('id') id: string, @Body() body: any) {
    try {
      await this.deckCardService.increment(Number(id), body.amount);
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
      await this.deckCardService.decrement(Number(id), body.amount);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
