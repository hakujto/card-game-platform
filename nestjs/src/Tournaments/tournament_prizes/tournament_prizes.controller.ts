import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TournamentPrizeService } from './tournament_prize.service';


function validate(data: any): void {
  if (data.placementFrom != null && Number(data.placementFrom) < 1) throw new Error('placement_from: must be >= 1');
  if (data.placementTo != null && Number(data.placementTo) < 1) throw new Error('placement_to: must be >= 1');
  if (!((data.placementTo == null || (data.placementFrom != null && data.placementTo >= data.placementFrom)))) throw new Error(`placement_to must be greater than or equal to placement_from`);
  if (!((data.placementFrom == null || data.placementFrom > 0))) throw new Error(`placement_from must be greater than zero`);
  if (!((data.amount == null || Number(data.amount) >= 0))) throw new Error(`Prize amount must not be negative`);
}

@Controller('tournament_prizes')
export class TournamentPrizeController {
  constructor(private readonly prisma: PrismaService, private readonly tournamentPrizeService: TournamentPrizeService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.tournamentPrize.findMany();
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.placementFrom !== undefined) data.placementFrom = body.placementFrom;
    if (body.placementTo !== undefined) data.placementTo = body.placementTo;
    if (body.prizeType !== undefined) data.prizeType = body.prizeType;
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.description !== undefined) data.description = body.description;
    if (body.packsCount !== undefined) data.packsCount = body.packsCount;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    try {
    validate(data);
      const entity = await this.prisma.tournamentPrize.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.tournamentPrize.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.placementFrom !== undefined) data.placementFrom = body.placementFrom;
    if (body.placementTo !== undefined) data.placementTo = body.placementTo;
    if (body.prizeType !== undefined) data.prizeType = body.prizeType;
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.description !== undefined) data.description = body.description;
    if (body.packsCount !== undefined) data.packsCount = body.packsCount;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    try {
    validate(data);
      const existing = await this.prisma.tournamentPrize.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.tournamentPrize.update({ where: { id: Number(id) }, data });
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
    if (body.placementFrom !== undefined) data.placementFrom = body.placementFrom;
    if (body.placementTo !== undefined) data.placementTo = body.placementTo;
    if (body.prizeType !== undefined) data.prizeType = body.prizeType;
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.description !== undefined) data.description = body.description;
    if (body.packsCount !== undefined) data.packsCount = body.packsCount;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    try {
    validate(data);
      const existing = await this.prisma.tournamentPrize.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.tournamentPrize.update({ where: { id: Number(id) }, data });
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
      await this.prisma.tournamentPrize.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Get('/:id/applies')
  async applies_to_placement(@Param('id') id: string, @Query('placement') placement: any) {
    let result: any;
    try {
      result = await this.tournamentPrizeService.applies_to_placement(Number(id), placement);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/award')
  @HttpCode(204)
  async award_to_player(@Param('id') id: string, @Body() body: any) {
    try {
      await this.tournamentPrizeService.award_to_player(Number(id), body.playerId);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
