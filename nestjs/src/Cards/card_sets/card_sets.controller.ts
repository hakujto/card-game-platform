import { BadRequestException, Body, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CardSetService } from './card_set.service';


function validate(data: any): void {
  if (data.code != null && !/[A-Z]{2,6}/.test(String(data.code))) throw new Error('code: invalid format');
  if (!((data.totalCards == null || data.totalCards > 0))) throw new Error(`Card set must have at least one card`);
  if ((data.rotationDate != null) && !((data.rotationDate == null || (data.releaseDate != null && data.rotationDate > data.releaseDate)))) throw new Error(`Rotation date must be after release date`);
  if ((data.isRotated === true) && !((data.rotationDate === undefined || data.rotationDate != null))) throw new Error(`Rotated set must have a rotation date`);
}

@Controller('card_sets')
export class CardSetController {
  constructor(private readonly prisma: PrismaService, private readonly cardSetService: CardSetService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ name: { contains: q } }, { code: { contains: q } }] } : undefined;
    const items = await this.prisma.cardSet.findMany(where ? { where } : undefined);
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.code !== undefined) data.code = body.code;
    if (body.releaseDate !== undefined) data.releaseDate = body.releaseDate != null ? new Date(body.releaseDate) : null;
    if (body.rotationDate !== undefined) data.rotationDate = body.rotationDate != null ? new Date(body.rotationDate) : null;
    if (body.setType !== undefined) data.setType = body.setType;
    if (body.totalCards !== undefined) data.totalCards = body.totalCards;
    if (body.isRotated !== undefined) data.isRotated = body.isRotated;
    if (body.description !== undefined) data.description = body.description;
    if (body.logoUrl !== undefined) data.logoUrl = body.logoUrl;
    try {
    validate(data);
      const entity = await this.prisma.cardSet.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.cardSet.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.code !== undefined) data.code = body.code;
    if (body.releaseDate !== undefined) data.releaseDate = body.releaseDate != null ? new Date(body.releaseDate) : null;
    if (body.rotationDate !== undefined) data.rotationDate = body.rotationDate != null ? new Date(body.rotationDate) : null;
    if (body.setType !== undefined) data.setType = body.setType;
    if (body.totalCards !== undefined) data.totalCards = body.totalCards;
    if (body.isRotated !== undefined) data.isRotated = body.isRotated;
    if (body.description !== undefined) data.description = body.description;
    if (body.logoUrl !== undefined) data.logoUrl = body.logoUrl;
    try {
    validate(data);
      const existing = await this.prisma.cardSet.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.cardSet.update({ where: { id: Number(id) }, data });
      return entity;
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
    if (body.code !== undefined) data.code = body.code;
    if (body.releaseDate !== undefined) data.releaseDate = body.releaseDate != null ? new Date(body.releaseDate) : null;
    if (body.rotationDate !== undefined) data.rotationDate = body.rotationDate != null ? new Date(body.rotationDate) : null;
    if (body.setType !== undefined) data.setType = body.setType;
    if (body.totalCards !== undefined) data.totalCards = body.totalCards;
    if (body.isRotated !== undefined) data.isRotated = body.isRotated;
    if (body.description !== undefined) data.description = body.description;
    if (body.logoUrl !== undefined) data.logoUrl = body.logoUrl;
    try {
    validate(data);
      const existing = await this.prisma.cardSet.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.cardSet.update({ where: { id: Number(id) }, data });
      return entity;
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Get('/:id/standard-legal')
  async is_legal_in_standard(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.cardSetService.is_legal_in_standard(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Get('/:id/legal')
  async is_legal_in_format(@Param('id') id: string, @Query('format') format: any) {
    let result: any;
    try {
      result = await this.cardSetService.is_legal_in_format(Number(id), format);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Get('/:id/rarity-count')
  async card_count_by_rarity(@Param('id') id: string, @Query('rarity') rarity: any) {
    let result: any;
    try {
      result = await this.cardSetService.card_count_by_rarity(Number(id), rarity);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/rotate')
  @HttpCode(204)
  async rotate_out(@Param('id') id: string) {
    try {
      await this.cardSetService.rotate_out(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
