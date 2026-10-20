import { BadRequestException, Body, ConflictException, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { StreamService } from './stream.service';


function validate(data: any): void {
  if (!((data.viewerCountPeak == null || data.viewerCountPeak >= 0))) throw new Error(`Peak viewer count must not be negative`);
  if ((data.actualStart != null) && !(data.status === 'LIVE')) throw new Error(`actual_start_requires_live_or_ended`);
  if ((data.endedAt != null) && !(data.status === 'ENDED')) throw new Error(`ended_at can only be set when stream status is Ended`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('scheduledStart' in r) { r.scheduledStart = r.scheduledStart; delete r.scheduledStart; }
  if ('actualStart' in r) { r.actualStart = r.actualStart; delete r.actualStart; }
  if ('endedAt' in r) { r.endedAt = r.endedAt; delete r.endedAt; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Scheduled': ['Live'],
  'Live': ['Ended']
};
function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

@Controller('streams')
export class StreamController {
  constructor(private readonly prisma: PrismaService, private readonly streamService: StreamService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ title: { contains: q } }] } : undefined;
    const items = await this.prisma.stream.findMany(where ? { where } : undefined);
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.streamUrl !== undefined) data.streamUrl = body.streamUrl;
    if (body.status !== undefined) data.status = body.status;
    if (body.platform !== undefined) data.platform = body.platform;
    if (body.language !== undefined) data.language = body.language;
    if (body.isOfficial !== undefined) data.isOfficial = body.isOfficial;
    if (body.viewerCountPeak !== undefined) data.viewerCountPeak = body.viewerCountPeak;
    if (body.scheduledStart !== undefined) data.scheduledStart = body.scheduledStart != null ? new Date(body.scheduledStart) : null;
    if (body.actualStart !== undefined) data.actualStart = body.actualStart != null ? new Date(body.actualStart) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.vodUrl !== undefined) data.vodUrl = body.vodUrl;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.streamerId !== undefined) data.streamerId = body.streamerId;
    try {
    validate(data);
      const entity = await this.prisma.stream.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.stream.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.streamUrl !== undefined) data.streamUrl = body.streamUrl;
    if (body.status !== undefined) data.status = body.status;
    if (body.platform !== undefined) data.platform = body.platform;
    if (body.language !== undefined) data.language = body.language;
    if (body.isOfficial !== undefined) data.isOfficial = body.isOfficial;
    if (body.viewerCountPeak !== undefined) data.viewerCountPeak = body.viewerCountPeak;
    if (body.scheduledStart !== undefined) data.scheduledStart = body.scheduledStart != null ? new Date(body.scheduledStart) : null;
    if (body.actualStart !== undefined) data.actualStart = body.actualStart != null ? new Date(body.actualStart) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.vodUrl !== undefined) data.vodUrl = body.vodUrl;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.streamerId !== undefined) data.streamerId = body.streamerId;
    try {
    validate(data);
      const existing = await this.prisma.stream.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.stream.update({ where: { id: Number(id) }, data });
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
    if (body.title !== undefined) data.title = body.title;
    if (body.streamUrl !== undefined) data.streamUrl = body.streamUrl;
    if (body.status !== undefined) data.status = body.status;
    if (body.platform !== undefined) data.platform = body.platform;
    if (body.language !== undefined) data.language = body.language;
    if (body.isOfficial !== undefined) data.isOfficial = body.isOfficial;
    if (body.viewerCountPeak !== undefined) data.viewerCountPeak = body.viewerCountPeak;
    if (body.scheduledStart !== undefined) data.scheduledStart = body.scheduledStart != null ? new Date(body.scheduledStart) : null;
    if (body.actualStart !== undefined) data.actualStart = body.actualStart != null ? new Date(body.actualStart) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.vodUrl !== undefined) data.vodUrl = body.vodUrl;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.streamerId !== undefined) data.streamerId = body.streamerId;
    try {
    validate(data);
      const existing = await this.prisma.stream.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.stream.update({ where: { id: Number(id) }, data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Post('/:id/live')
  @HttpCode(204)
  async go_live(@Param('id') id: string) {
    try {
      await this.streamService.go_live(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/end')
  @HttpCode(204)
  async end(@Param('id') id: string) {
    try {
      await this.streamService.end(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch('/:id/viewers')
  @HttpCode(204)
  async update_viewer_peak(@Param('id') id: string, @Body() body: any) {
    try {
      await this.streamService.update_viewer_peak(Number(id), body.count);
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
      result = await this.streamService.duration_minutes(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }


  @Patch(':id/transitions/scheduled-to-live')
  async transitionScheduledToLive(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Streamer', 'Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Scheduled -> Live');
    const entity = await this.prisma.stream.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Live');
      if ((entity as any).streamUrl == null) throw new Error('stream_url is required for Scheduled -> Live');
      return await this.prisma.stream.update({ where: { id: Number(id) }, data: { status: 'Live' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/live-to-ended')
  async transitionLiveToEnded(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Streamer', 'Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Live -> Ended');
    const entity = await this.prisma.stream.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Ended');
      return await this.prisma.stream.update({ where: { id: Number(id) }, data: { status: 'Ended' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/ended-to-live')
  async transitionEndedToLive(@Param('id') id: string) {
    throw new ConflictException('Transition Ended -> Live is not allowed');
  }
}
