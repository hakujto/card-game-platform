import { BadRequestException, Body, ConflictException, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TradeDisputeService } from './trade_dispute.service';


function validate(data: any): void {
  if ((data.resolvedAt != null) && !(data.status === 'RESOLVED')) throw new Error(`resolved_at_requires_terminal_status`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('openedAt' in r) { r.openedAt = r.openedAt; delete r.openedAt; }
  if ('resolvedAt' in r) { r.resolvedAt = r.resolvedAt; delete r.resolvedAt; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Open': ['UnderReview'],
  'UnderReview': ['Resolved', 'Escalated'],
  'Escalated': ['Resolved']
};
function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

@Controller('trade_disputes')
export class TradeDisputeController {
  constructor(private readonly prisma: PrismaService, private readonly tradeDisputeService: TradeDisputeService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.tradeDispute.findMany();
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.reason !== undefined) data.reason = body.reason;
    if (body.description !== undefined) data.description = body.description;
    if (body.resolution !== undefined) data.resolution = body.resolution;
    if (body.openedAt !== undefined) data.openedAt = body.openedAt != null ? new Date(body.openedAt) : null;
    if (body.resolvedAt !== undefined) data.resolvedAt = body.resolvedAt != null ? new Date(body.resolvedAt) : null;
    if (body.transactionId !== undefined) data.transactionId = body.transactionId;
    if (body.openedById !== undefined) data.openedById = body.openedById;
    if (body.resolvedById !== undefined) data.resolvedById = body.resolvedById;
    try {
    validate(data);
      const entity = await this.prisma.tradeDispute.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.tradeDispute.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Post('/:id/escalate')
  @HttpCode(204)
  async escalate(@Param('id') id: string) {
    try {
      await this.tradeDisputeService.escalate(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/resolve')
  @HttpCode(204)
  async resolve(@Param('id') id: string, @Body() body: any, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['admin', 'moderator'].includes(userRole)) throw new ForbiddenException('Insufficient role for resolve');
    try {
      await this.tradeDisputeService.resolve(Number(id), body.resolutionText);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/close')
  @HttpCode(204)
  async close_resolved(@Param('id') id: string) {
    try {
      await this.tradeDisputeService.close_resolved(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/review')
  @HttpCode(204)
  async review(@Param('id') id: string) {
    try {
      await this.tradeDisputeService.review(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }


  @Patch(':id/transitions/open-to-underreview')
  async transitionOpenToUnderReview(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Moderator'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Open -> UnderReview');
    const entity = await this.prisma.tradeDispute.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'UnderReview');
      return await this.prisma.tradeDispute.update({ where: { id: Number(id) }, data: { status: 'UnderReview' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/underreview-to-resolved')
  async transitionUnderReviewToResolved(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Moderator'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition UnderReview -> Resolved');
    const entity = await this.prisma.tradeDispute.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Resolved');
      if ((entity as any).resolution == null) throw new Error('resolution is required for UnderReview -> Resolved');
      return await this.prisma.tradeDispute.update({ where: { id: Number(id) }, data: { status: 'Resolved' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/underreview-to-escalated')
  async transitionUnderReviewToEscalated(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition UnderReview -> Escalated');
    const entity = await this.prisma.tradeDispute.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Escalated');
      return await this.prisma.tradeDispute.update({ where: { id: Number(id) }, data: { status: 'Escalated' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/escalated-to-resolved')
  async transitionEscalatedToResolved(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Escalated -> Resolved');
    const entity = await this.prisma.tradeDispute.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Resolved');
      if ((entity as any).resolution == null) throw new Error('resolution is required for Escalated -> Resolved');
      return await this.prisma.tradeDispute.update({ where: { id: Number(id) }, data: { status: 'Resolved' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/resolved-to-open')
  async transitionResolvedToOpen(@Param('id') id: string) {
    throw new ConflictException('Transition Resolved -> Open is not allowed');
  }
}
