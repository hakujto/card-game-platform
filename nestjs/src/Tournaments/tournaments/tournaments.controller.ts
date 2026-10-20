import { BadRequestException, Body, ConflictException, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TournamentService } from './tournament.service';


function validate(data: any): void {
  if (data.maxPlayers != null && Number(data.maxPlayers) < 2) throw new Error('max_players: must be >= 2');
  if (data.maxPlayers != null && Number(data.maxPlayers) > 512) throw new Error('max_players: must be <= 512');
  if (!((data.maxPlayers == null || (data.maxPlayers >= 2 && data.maxPlayers <= 512)))) throw new Error(`Tournament must allow between 2 and 512 players`);
  if (!((data.entryFee == null || Number(data.entryFee) >= 0))) throw new Error(`Entry fee must not be negative`);
  if (!((data.prizePool == null || Number(data.prizePool) >= 0))) throw new Error(`Prize pool must not be negative`);
  if ((data.endTime != null) && !((data.endTime == null || (data.startTime != null && data.endTime > data.startTime)))) throw new Error(`End time must be after start time`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('startTime' in r) { r.startTime = r.startTime; delete r.startTime; }
  if ('endTime' in r) { r.endTime = r.endTime; delete r.endTime; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Draft': ['Registration'],
  'Registration': ['Ongoing', 'Cancelled'],
  'Ongoing': ['Completed', 'Cancelled']
};
function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

@Controller('tournaments')
export class TournamentController {
  constructor(private readonly prisma: PrismaService, private readonly tournamentService: TournamentService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ name: { contains: q } }, { description: { contains: q } }] } : undefined;
    const items = await this.prisma.tournament.findMany(where ? { where } : undefined);
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.publicId !== undefined) data.publicId = body.publicId;
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.status !== undefined) data.status = body.status;
    if (body.bracketData !== undefined) data.bracketData = body.bracketData;
    if (body.format !== undefined) data.format = body.format;
    if (body.tournamentType !== undefined) data.tournamentType = body.tournamentType;
    if (body.maxPlayers !== undefined) data.maxPlayers = body.maxPlayers;
    if (body.entryFee !== undefined) data.entryFee = body.entryFee;
    if (body.prizePool !== undefined) data.prizePool = body.prizePool;
    if (body.startTime !== undefined) data.startTime = body.startTime != null ? new Date(body.startTime) : null;
    if (body.endTime !== undefined) data.endTime = body.endTime != null ? new Date(body.endTime) : null;
    if (body.isOnline !== undefined) data.isOnline = body.isOnline;
    if (body.location !== undefined) data.location = body.location;
    if (body.rulesText !== undefined) data.rulesText = body.rulesText;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
    if (body.organizerId !== undefined) data.organizerId = body.organizerId;
    try {
    validate(data);
      const entity = await this.prisma.tournament.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.tournament.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.publicId !== undefined) data.publicId = body.publicId;
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.bracketData !== undefined) data.bracketData = body.bracketData;
    if (body.format !== undefined) data.format = body.format;
    if (body.tournamentType !== undefined) data.tournamentType = body.tournamentType;
    if (body.maxPlayers !== undefined) data.maxPlayers = body.maxPlayers;
    if (body.entryFee !== undefined) data.entryFee = body.entryFee;
    if (body.prizePool !== undefined) data.prizePool = body.prizePool;
    if (body.startTime !== undefined) data.startTime = body.startTime != null ? new Date(body.startTime) : null;
    if (body.endTime !== undefined) data.endTime = body.endTime != null ? new Date(body.endTime) : null;
    if (body.isOnline !== undefined) data.isOnline = body.isOnline;
    if (body.location !== undefined) data.location = body.location;
    if (body.rulesText !== undefined) data.rulesText = body.rulesText;
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
    if (body.organizerId !== undefined) data.organizerId = body.organizerId;
    try {
    validate(data);
      const existing = await this.prisma.tournament.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.tournament.update({ where: { id: Number(id) }, data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.publicId !== undefined) data.publicId = body.publicId;
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.bracketData !== undefined) data.bracketData = body.bracketData;
    if (body.format !== undefined) data.format = body.format;
    if (body.tournamentType !== undefined) data.tournamentType = body.tournamentType;
    if (body.maxPlayers !== undefined) data.maxPlayers = body.maxPlayers;
    if (body.entryFee !== undefined) data.entryFee = body.entryFee;
    if (body.prizePool !== undefined) data.prizePool = body.prizePool;
    if (body.startTime !== undefined) data.startTime = body.startTime != null ? new Date(body.startTime) : null;
    if (body.endTime !== undefined) data.endTime = body.endTime != null ? new Date(body.endTime) : null;
    if (body.isOnline !== undefined) data.isOnline = body.isOnline;
    if (body.location !== undefined) data.location = body.location;
    if (body.rulesText !== undefined) data.rulesText = body.rulesText;
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
    if (body.organizerId !== undefined) data.organizerId = body.organizerId;
    try {
    validate(data);
      const existing = await this.prisma.tournament.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.tournament.update({ where: { id: Number(id) }, data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Post('/:id/start')
  @HttpCode(204)
  async start(@Param('id') id: string) {
    try {
      await this.tournamentService.start(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/cancel')
  @HttpCode(204)
  async cancel(@Param('id') id: string) {
    try {
      await this.tournamentService.cancel(Number(id));
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
      await this.tournamentService.complete(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/rounds')
  @HttpCode(204)
  async generate_round(@Param('id') id: string) {
    try {
      await this.tournamentService.generate_round(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/prizes')
  async calculate_prize_distribution(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.tournamentService.calculate_prize_distribution(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/register')
  @HttpCode(204)
  async register_player(@Param('id') id: string, @Body() body: any) {
    try {
      await this.tournamentService.register_player(Number(id), body.playerId, body.deckId);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/full')
  async is_full(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.tournamentService.is_full(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }


  @Patch(':id/transitions/draft-to-registration')
  async transitionDraftToRegistration(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Organizer'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Draft -> Registration');
    const entity = await this.prisma.tournament.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Registration');
      if ((entity as any).name == null) throw new Error('name is required for Draft -> Registration');
      if ((entity as any).startTime == null) throw new Error('start_time is required for Draft -> Registration');
      return await this.prisma.tournament.update({ where: { id: Number(id) }, data: { status: 'Registration' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/registration-to-ongoing')
  async transitionRegistrationToOngoing(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Organizer'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Registration -> Ongoing');
    const entity = await this.prisma.tournament.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Ongoing');
      return await this.prisma.tournament.update({ where: { id: Number(id) }, data: { status: 'Ongoing' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/registration-to-cancelled')
  async transitionRegistrationToCancelled(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Organizer'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Registration -> Cancelled');
    const entity = await this.prisma.tournament.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Cancelled');
      return await this.prisma.tournament.update({ where: { id: Number(id) }, data: { status: 'Cancelled' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/ongoing-to-completed')
  async transitionOngoingToCompleted(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Organizer'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Ongoing -> Completed');
    const entity = await this.prisma.tournament.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Completed');
      return await this.prisma.tournament.update({ where: { id: Number(id) }, data: { status: 'Completed' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/ongoing-to-cancelled')
  async transitionOngoingToCancelled(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Ongoing -> Cancelled');
    const entity = await this.prisma.tournament.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Cancelled');
      return await this.prisma.tournament.update({ where: { id: Number(id) }, data: { status: 'Cancelled' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/completed-to-draft')
  async transitionCompletedToDraft(@Param('id') id: string) {
    throw new ConflictException('Transition Completed -> Draft is not allowed');
  }

  @Patch(':id/transitions/cancelled-to-draft')
  async transitionCancelledToDraft(@Param('id') id: string) {
    throw new ConflictException('Transition Cancelled -> Draft is not allowed');
  }
}
