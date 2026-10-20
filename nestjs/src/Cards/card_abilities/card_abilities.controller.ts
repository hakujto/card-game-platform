import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CardAbilityService } from './card_ability.service';


function validate(data: any): void {
  if ((data.abilityType === 'KEYWORD') && !((data.keyword === undefined || data.keyword != null))) throw new Error(`Keyword ability must have a keyword name`);
}

@Controller('card_abilities')
export class CardAbilityController {
  constructor(private readonly prisma: PrismaService, private readonly cardAbilityService: CardAbilityService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ keyword: { contains: q } }, { abilityText: { contains: q } }] } : undefined;
    const items = await this.prisma.cardAbility.findMany(where ? { where } : undefined);
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.abilityType !== undefined) data.abilityType = body.abilityType;
    if (body.keyword !== undefined) data.keyword = body.keyword;
    if (body.abilityText !== undefined) data.abilityText = body.abilityText;
    if (body.timing !== undefined) data.timing = body.timing;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
    validate(data);
      const entity = await this.prisma.cardAbility.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.cardAbility.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.abilityType !== undefined) data.abilityType = body.abilityType;
    if (body.keyword !== undefined) data.keyword = body.keyword;
    if (body.abilityText !== undefined) data.abilityText = body.abilityText;
    if (body.timing !== undefined) data.timing = body.timing;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
    validate(data);
      const existing = await this.prisma.cardAbility.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.cardAbility.update({ where: { id: Number(id) }, data });
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
    if (body.abilityType !== undefined) data.abilityType = body.abilityType;
    if (body.keyword !== undefined) data.keyword = body.keyword;
    if (body.abilityText !== undefined) data.abilityText = body.abilityText;
    if (body.timing !== undefined) data.timing = body.timing;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
    validate(data);
      const existing = await this.prisma.cardAbility.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.cardAbility.update({ where: { id: Number(id) }, data });
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
      await this.prisma.cardAbility.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Get('/:id/usable')
  async is_usable_at(@Param('id') id: string, @Query('timing') timing: any) {
    let result: any;
    try {
      result = await this.cardAbilityService.is_usable_at(Number(id), timing);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Get('/:id/describe')
  async describe(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.cardAbilityService.describe(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
