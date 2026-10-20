import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TournamentJudgeService } from './tournament_judge.service';


@Controller('tournament_judges')
export class TournamentJudgeController {
  constructor(private readonly prisma: PrismaService, private readonly tournamentJudgeService: TournamentJudgeService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.tournamentJudge.findMany();
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.role !== undefined) data.role = body.role;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    try {
      const entity = await this.prisma.tournamentJudge.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.tournamentJudge.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Delete(':id')
  @HttpCode(204)
  async remove(@Param('id') id: string) {
    try {
      await this.prisma.tournamentJudge.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Post('/:id/promote')
  @HttpCode(204)
  async promote_to_head(@Param('id') id: string) {
    try {
      await this.tournamentJudgeService.promote_to_head(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
