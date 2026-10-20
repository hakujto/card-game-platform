import { BadRequestException, Body, Controller, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { PlayerSeasonStatsService } from './player_season_stats.service';


function validate(data: any): void {
  if (!((data.wins == null || data.wins >= 0))) throw new Error(`Season wins must not be negative`);
  if (!((data.losses == null || data.losses >= 0))) throw new Error(`Season losses must not be negative`);
  if (!((data.tournamentWins == null || data.tournamentWins >= 0))) throw new Error(`Season tournament wins must not be negative`);
  if (!((data.seasonPoints == null || data.seasonPoints >= 0))) throw new Error(`Season points must not be negative`);
}

@Controller('player_season_statses')
export class PlayerSeasonStatsController {
  constructor(private readonly prisma: PrismaService, private readonly playerSeasonStatsService: PlayerSeasonStatsService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.playerSeasonStats.findMany();
    return items;
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.playerSeasonStats.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Get('/:id/win-rate')
  async win_rate(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.playerSeasonStatsService.win_rate(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Patch('/:id/points')
  @HttpCode(204)
  async add_points(@Param('id') id: string, @Body() body: any) {
    try {
      await this.playerSeasonStatsService.add_points(Number(id), body.points);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/tournament-win')
  @HttpCode(204)
  async record_tournament_win(@Param('id') id: string) {
    try {
      await this.playerSeasonStatsService.record_tournament_win(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
