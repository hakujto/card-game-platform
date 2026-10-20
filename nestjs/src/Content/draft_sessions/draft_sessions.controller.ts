import { BadRequestException, Body, ConflictException, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { DraftSessionService } from './draft_session.service';


function validate(data: any): void {
  if (!((data.seats == null || (data.seats >= 2 && data.seats <= 16)))) throw new Error(`Draft session must have between 2 and 16 seats`);
  if (!((data.timePerPickSeconds == null || data.timePerPickSeconds > 0))) throw new Error(`Time per pick must be greater than zero`);
  if ((data.completedAt != null) && !(data.status === 'COMPLETED')) throw new Error(`completed_at can only be set when draft status is Completed`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('completedAt' in r) { r.completedAt = r.completedAt; delete r.completedAt; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'WaitingForPlayers': ['Drafting', 'Abandoned'],
  'Drafting': ['Completed', 'Abandoned']
};
function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

@Controller('draft_sessions')
export class DraftSessionController {
  constructor(private readonly prisma: PrismaService, private readonly draftSessionService: DraftSessionService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.draftSession.findMany();
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.draftType !== undefined) data.draftType = body.draftType;
    if (body.packContents !== undefined) data.packContents = body.packContents;
    if (body.seats !== undefined) data.seats = body.seats;
    if (body.timePerPickSeconds !== undefined) data.timePerPickSeconds = body.timePerPickSeconds;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.completedAt !== undefined) data.completedAt = body.completedAt != null ? new Date(body.completedAt) : null;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
    try {
    validate(data);
      const entity = await this.prisma.draftSession.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.draftSession.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Post('/:id/start')
  @HttpCode(204)
  async start(@Param('id') id: string) {
    try {
      await this.draftSessionService.start(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/abandon')
  @HttpCode(204)
  async abandon(@Param('id') id: string) {
    try {
      await this.draftSessionService.abandon(Number(id));
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
      await this.draftSessionService.complete(Number(id));
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
      result = await this.draftSessionService.is_full(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }


  @Patch(':id/transitions/waitingforplayers-to-drafting')
  async transitionWaitingForPlayersToDrafting(@Param('id') id: string) {
    const entity = await this.prisma.draftSession.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Drafting');
      return await this.prisma.draftSession.update({ where: { id: Number(id) }, data: { status: 'Drafting' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/drafting-to-completed')
  async transitionDraftingToCompleted(@Param('id') id: string) {
    const entity = await this.prisma.draftSession.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Completed');
      return await this.prisma.draftSession.update({ where: { id: Number(id) }, data: { status: 'Completed' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/drafting-to-abandoned')
  async transitionDraftingToAbandoned(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Organizer'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Drafting -> Abandoned');
    const entity = await this.prisma.draftSession.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Abandoned');
      return await this.prisma.draftSession.update({ where: { id: Number(id) }, data: { status: 'Abandoned' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/waitingforplayers-to-abandoned')
  async transitionWaitingForPlayersToAbandoned(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Organizer'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition WaitingForPlayers -> Abandoned');
    const entity = await this.prisma.draftSession.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Abandoned');
      return await this.prisma.draftSession.update({ where: { id: Number(id) }, data: { status: 'Abandoned' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/completed-to-drafting')
  async transitionCompletedToDrafting(@Param('id') id: string) {
    throw new ConflictException('Transition Completed -> Drafting is not allowed');
  }

  @Patch(':id/transitions/abandoned-to-drafting')
  async transitionAbandonedToDrafting(@Param('id') id: string) {
    throw new ConflictException('Transition Abandoned -> Drafting is not allowed');
  }
}
