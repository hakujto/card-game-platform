import { BadRequestException, Body, Controller, Get, HttpCode, NotFoundException, Param, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TournamentRoundService } from './tournament_round.service';


function validate(data: any): void {
  if (!((data.roundNumber == null || data.roundNumber > 0))) throw new Error(`Round number must be greater than zero`);
  if (!((data.timeLimitMinutes == null || data.timeLimitMinutes > 0))) throw new Error(`Round time limit must be greater than zero`);
  if ((data.endedAt != null) && !((data.endedAt == null || (data.startedAt != null && data.endedAt > data.startedAt)))) throw new Error(`Round end time must be after start time`);
  if ((data.status === 'COMPLETED') && !((data.startedAt === undefined || data.startedAt != null))) throw new Error(`Completed round must have a start time`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('startedAt' in r) { r.startedAt = r.startedAt; delete r.startedAt; }
  if ('endedAt' in r) { r.endedAt = r.endedAt; delete r.endedAt; }
  return r;
}

@Controller('tournament_rounds')
export class TournamentRoundController {
  constructor(private readonly prisma: PrismaService, private readonly tournamentRoundService: TournamentRoundService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.tournamentRound.findMany();
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.roundNumber !== undefined) data.roundNumber = body.roundNumber;
    if (body.status !== undefined) data.status = body.status;
    if (body.startedAt !== undefined) data.startedAt = body.startedAt != null ? new Date(body.startedAt) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.timeLimitMinutes !== undefined) data.timeLimitMinutes = body.timeLimitMinutes;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    try {
    validate(data);
      const entity = await this.prisma.tournamentRound.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.tournamentRound.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Post('/:id/start')
  @HttpCode(204)
  async start(@Param('id') id: string) {
    try {
      await this.tournamentRoundService.start(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/complete')
  @HttpCode(204)
  async complete(@Param('id') id: string) {
    try {
      await this.tournamentRoundService.complete(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/pairings')
  @HttpCode(204)
  async generate_pairings(@Param('id') id: string) {
    try {
      await this.tournamentRoundService.generate_pairings(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/time-expired')
  async is_time_expired(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.tournamentRoundService.is_time_expired(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
