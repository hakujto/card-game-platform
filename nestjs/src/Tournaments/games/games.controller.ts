import { BadRequestException, Body, Controller, Get, HttpCode, NotFoundException, Param, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { GameService } from './game.service';


function validate(data: any): void {
  if (data.gameNumber != null && Number(data.gameNumber) < 1) throw new Error('game_number: must be >= 1');
  if (data.gameNumber != null && Number(data.gameNumber) > 3) throw new Error('game_number: must be <= 3');
  if (!((data.gameNumber == null || (data.gameNumber >= 1 && data.gameNumber <= 3)))) throw new Error(`Game number must be between 1 and 3 (best-of-3)`);
  if ((data.turnsPlayed != null) && !((data.turnsPlayed == null || data.turnsPlayed > 0))) throw new Error(`Turns played must be greater than zero`);
  if ((data.durationSeconds != null) && !((data.durationSeconds == null || data.durationSeconds > 0))) throw new Error(`Game duration must be greater than zero`);
  if ((data.winnerSide === 'DRAW') && !(data.winnerId == null)) throw new Error(`A draw cannot have a winner`);
  if (((data.winnerSide != null && data.winnerSide !== 'DRAW')) && !((data.winnerId === undefined || data.winnerId != null))) throw new Error(`A decisive game must have a winner player set`);
}

@Controller('games')
export class GameController {
  constructor(private readonly prisma: PrismaService, private readonly gameService: GameService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.game.findMany();
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.gameNumber !== undefined) data.gameNumber = body.gameNumber;
    if (body.winnerSide !== undefined) data.winnerSide = body.winnerSide;
    if (body.complexityScore !== undefined) data.complexityScore = body.complexityScore;
    if (body.turnsPlayed !== undefined) data.turnsPlayed = body.turnsPlayed;
    if (body.durationSeconds !== undefined) data.durationSeconds = body.durationSeconds;
    if (body.endedBy !== undefined) data.endedBy = body.endedBy;
    if (body.replayUrl !== undefined) data.replayUrl = body.replayUrl;
    if (body.matchId !== undefined) data.matchId = body.matchId;
    if (body.winnerId !== undefined) data.winnerId = body.winnerId;
    try {
    validate(data);
      const entity = await this.prisma.game.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.game.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Post('/:id/winner')
  @HttpCode(204)
  async record_winner(@Param('id') id: string, @Body() body: any) {
    try {
      await this.gameService.record_winner(Number(id), body.winnerSide);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/duration')
  async duration_minutes(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.gameService.duration_minutes(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
