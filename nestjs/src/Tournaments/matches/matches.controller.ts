import { BadRequestException, Body, ConflictException, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { MatchService } from './match.service';


function validate(data: any): void {
  if (!(((data.player1Wins == null || data.player1Wins >= 0) && (data.player2Wins == null || data.player2Wins >= 0)))) throw new Error(`Win counts must not be negative`);
  if (!(((data.player1Wins == null || (data.player1Wins >= 0 && data.player1Wins <= 2)) && (data.player2Wins == null || (data.player2Wins >= 0 && data.player2Wins <= 2))))) throw new Error(`Win counts cannot exceed 2 in a best-of-3 match`);
  if ((data.status === 'BYE') && !(data.player2Id == null)) throw new Error(`BYE match must not have a second player`);
  if ((data.endedAt != null) && !((data.endedAt == null || (data.startedAt != null && data.endedAt > data.startedAt)))) throw new Error(`Match end time must be after start time`);
  if ((data.status === 'COMPLETED') && !((data.startedAt === undefined || data.startedAt != null))) throw new Error(`Completed match must have a start time`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('startedAt' in r) { r.startedAt = r.startedAt; delete r.startedAt; }
  if ('endedAt' in r) { r.endedAt = r.endedAt; delete r.endedAt; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Pending': ['Active', 'BYE'],
  'Active': ['Completed', 'Draw']
};
function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

@Controller('matches')
export class MatchController {
  constructor(private readonly prisma: PrismaService, private readonly matchService: MatchService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.match.findMany();
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.tableNumber !== undefined) data.tableNumber = body.tableNumber;
    if (body.status !== undefined) data.status = body.status;
    if (body.player1Wins !== undefined) data.player1Wins = body.player1Wins;
    if (body.player2Wins !== undefined) data.player2Wins = body.player2Wins;
    if (body.startedAt !== undefined) data.startedAt = body.startedAt != null ? new Date(body.startedAt) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.resultNotes !== undefined) data.resultNotes = body.resultNotes;
    if (body.roundId !== undefined) data.roundId = body.roundId;
    if (body.player1Id !== undefined) data.player1Id = body.player1Id;
    if (body.player2Id !== undefined) data.player2Id = body.player2Id;
    try {
    validate(data);
      const entity = await this.prisma.match.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.match.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Post('/:id/record')
  @HttpCode(204)
  async record_result(@Param('id') id: string, @Body() body: any) {
    try {
      await this.matchService.record_result(Number(id), body.p1Wins, body.p2Wins);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/finalize')
  @HttpCode(204)
  async finalize_result(@Param('id') id: string) {
    try {
      await this.matchService.finalize_result(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/winner')
  async determine_winner(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.matchService.determine_winner(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/concede')
  @HttpCode(204)
  async concede(@Param('id') id: string, @Body() body: any) {
    try {
      await this.matchService.concede(Number(id), body.playerId);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/draw')
  @HttpCode(204)
  async draw(@Param('id') id: string) {
    try {
      await this.matchService.draw(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }


  @Patch(':id/transitions/pending-to-active')
  async transitionPendingToActive(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Judge', 'HeadJudge', 'Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Pending -> Active');
    const entity = await this.prisma.match.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Active');
      return await this.prisma.match.update({ where: { id: Number(id) }, data: { status: 'Active' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/active-to-completed')
  async transitionActiveToCompleted(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Judge', 'HeadJudge', 'Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Active -> Completed');
    const entity = await this.prisma.match.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Completed');
      return await this.prisma.match.update({ where: { id: Number(id) }, data: { status: 'Completed' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/active-to-draw')
  async transitionActiveToDraw(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Judge', 'HeadJudge', 'Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Active -> Draw');
    const entity = await this.prisma.match.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Draw');
      return await this.prisma.match.update({ where: { id: Number(id) }, data: { status: 'Draw' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/pending-to-bye')
  async transitionPendingToBYE(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Judge', 'HeadJudge', 'Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Pending -> BYE');
    const entity = await this.prisma.match.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'BYE');
      return await this.prisma.match.update({ where: { id: Number(id) }, data: { status: 'BYE' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/completed-to-active')
  async transitionCompletedToActive(@Param('id') id: string) {
    throw new ConflictException('Transition Completed -> Active is not allowed');
  }

  @Patch(':id/transitions/draw-to-active')
  async transitionDrawToActive(@Param('id') id: string) {
    throw new ConflictException('Transition Draw -> Active is not allowed');
  }

  @Patch(':id/transitions/bye-to-active')
  async transitionBYEToActive(@Param('id') id: string) {
    throw new ConflictException('Transition BYE -> Active is not allowed');
  }
}
