import { BadRequestException, Body, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { AchievementService } from './achievement.service';


function validate(data: any): void {
  if (!((data.points == null || data.points > 0))) throw new Error(`Achievement must award at least one point`);
}

@Controller('achievements')
export class AchievementController {
  constructor(private readonly prisma: PrismaService, private readonly achievementService: AchievementService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ name: { contains: q } }, { description: { contains: q } }] } : undefined;
    const items = await this.prisma.achievement.findMany(where ? { where } : undefined);
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.iconUrl !== undefined) data.iconUrl = body.iconUrl;
    if (body.points !== undefined) data.points = body.points;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
    try {
    validate(data);
      const entity = await this.prisma.achievement.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.achievement.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.iconUrl !== undefined) data.iconUrl = body.iconUrl;
    if (body.points !== undefined) data.points = body.points;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
    try {
    validate(data);
      const existing = await this.prisma.achievement.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.achievement.update({ where: { id: Number(id) }, data });
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
    if (body.description !== undefined) data.description = body.description;
    if (body.iconUrl !== undefined) data.iconUrl = body.iconUrl;
    if (body.points !== undefined) data.points = body.points;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
    try {
    validate(data);
      const existing = await this.prisma.achievement.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.achievement.update({ where: { id: Number(id) }, data });
      return entity;
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Get('/:id/point-value')
  async point_value(@Param('id') id: string, @Query('multiplier') multiplier: any) {
    let result: any;
    try {
      result = await this.achievementService.point_value(Number(id), multiplier);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/reveal')
  @HttpCode(204)
  async reveal(@Param('id') id: string) {
    try {
      await this.achievementService.reveal(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
