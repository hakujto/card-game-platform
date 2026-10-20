import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CardRulingService } from './card_ruling.service';


@Controller('card_rulings')
export class CardRulingController {
  constructor(private readonly prisma: PrismaService, private readonly cardRulingService: CardRulingService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.cardRuling.findMany();
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.rulingText !== undefined) data.rulingText = body.rulingText;
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.source !== undefined) data.source = body.source;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
      const entity = await this.prisma.cardRuling.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.cardRuling.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Delete(':id')
  @HttpCode(204)
  async remove(@Param('id') id: string) {
    try {
      await this.prisma.cardRuling.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Get('/:id/current')
  async is_current(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.cardRulingService.is_current(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Get('/:id/supersedes')
  async supersedes_previous(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.cardRulingService.supersedes_previous(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
