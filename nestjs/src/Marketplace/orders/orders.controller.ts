import { BadRequestException, Body, ConflictException, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { OrderService } from './order.service';


function validate(data: any): void {
  if (data.currency != null && !/[A-Z]{3}/.test(String(data.currency))) throw new Error('currency: invalid format');
  if ((data.status === 'Shipped') && data.trackingNumber == null) throw new Error('tracking_number is required');
  if ((data.status === 'Paid') && data.paidAt == null) throw new Error('paid_at is required');
  if (!((data.total == null || Number(data.total) >= 0))) throw new Error(`Order total must not be negative`);
  if (!((data.discountApplied == null || (data.total != null && Number(data.discountApplied) <= Number(data.total))))) throw new Error(`Discount applied cannot exceed order total`);
  if ((data.status === 'PAID') && !((data.paidAt === undefined || data.paidAt != null))) throw new Error(`Paid order must have paid_at set`);
  if ((data.status === 'SHIPPED') && !((data.trackingNumber === undefined || data.trackingNumber != null))) throw new Error(`Shipped order must have a tracking number`);
  if ((data.shippedAt != null) && !(data.status === 'SHIPPED')) throw new Error(`shipped_at_requires_shipped_status`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  delete r.paymentReference;
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('paidAt' in r) { r.paidAt = r.paidAt; delete r.paidAt; }
  if ('shippedAt' in r) { r.shippedAt = r.shippedAt; delete r.shippedAt; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Pending': ['Paid', 'Cancelled'],
  'Paid': ['Processing', 'Cancelled'],
  'Processing': ['Shipped'],
  'Shipped': ['Completed'],
  'Completed': ['Refunded']
};
function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

@Controller('orders')
export class OrderController {
  constructor(private readonly prisma: PrismaService, private readonly orderService: OrderService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.order.findMany();
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.total !== undefined) data.total = body.total;
    if (body.discountApplied !== undefined) data.discountApplied = body.discountApplied;
    if (body.currency !== undefined) data.currency = body.currency;
    if (body.paymentMethod !== undefined) data.paymentMethod = body.paymentMethod;
    if (body.paymentReference !== undefined) data.paymentReference = body.paymentReference;
    if (body.shippingAddress !== undefined) data.shippingAddress = body.shippingAddress;
    if (body.trackingNumber !== undefined) data.trackingNumber = body.trackingNumber;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.paidAt !== undefined) data.paidAt = body.paidAt != null ? new Date(body.paidAt) : null;
    if (body.shippedAt !== undefined) data.shippedAt = body.shippedAt != null ? new Date(body.shippedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.couponId !== undefined) data.couponId = body.couponId;
    try {
    validate(data);
      const entity = await this.prisma.order.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string, @Req() request: any) {
    const entity = await this.prisma.order.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    if (entity.playerId !== (request as any).userId) throw new ForbiddenException('You do not own this resource.');
    return applyProjection(entity);
  }

  @Delete('/:id/cancel')
  @HttpCode(204)
  async cancel(@Param('id') id: string) {
    try {
      await this.orderService.cancel(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/pay')
  async pay(@Param('id') id: string, @Body() body: any) {
    let result: any;
    try {
      result = await this.orderService.pay(Number(id), body.paymentRef);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/process-payment')
  async process_payment(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.orderService.process_payment(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Get('/:id/total')
  async calculate_total(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.orderService.calculate_total(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Patch('/:id/discount')
  async apply_discount(@Param('id') id: string, @Body() body: any) {
    let result: any;
    try {
      result = await this.orderService.apply_discount(Number(id), body.percent);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/refund')
  @HttpCode(204)
  async refund(@Param('id') id: string) {
    try {
      await this.orderService.refund(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }


  @Patch(':id/transitions/pending-to-paid')
  async transitionPendingToPaid(@Param('id') id: string) {
    const entity = await this.prisma.order.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Paid');
      if ((entity as any).paymentMethod == null) throw new Error('payment_method is required for Pending -> Paid');
      return await this.prisma.order.update({ where: { id: Number(id) }, data: { status: 'Paid' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/paid-to-processing')
  async transitionPaidToProcessing(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Staff'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Paid -> Processing');
    const entity = await this.prisma.order.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Processing');
      return await this.prisma.order.update({ where: { id: Number(id) }, data: { status: 'Processing' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/processing-to-shipped')
  async transitionProcessingToShipped(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Staff'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Processing -> Shipped');
    const entity = await this.prisma.order.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Shipped');
      if ((entity as any).trackingNumber == null) throw new Error('tracking_number is required for Processing -> Shipped');
      return await this.prisma.order.update({ where: { id: Number(id) }, data: { status: 'Shipped' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/shipped-to-completed')
  async transitionShippedToCompleted(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Staff'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Shipped -> Completed');
    const entity = await this.prisma.order.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Completed');
      return await this.prisma.order.update({ where: { id: Number(id) }, data: { status: 'Completed' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/pending-to-cancelled')
  async transitionPendingToCancelled(@Param('id') id: string) {
    const entity = await this.prisma.order.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Cancelled');
      return await this.prisma.order.update({ where: { id: Number(id) }, data: { status: 'Cancelled' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/paid-to-cancelled')
  async transitionPaidToCancelled(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin', 'Staff'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Paid -> Cancelled');
    const entity = await this.prisma.order.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Cancelled');
      return await this.prisma.order.update({ where: { id: Number(id) }, data: { status: 'Cancelled' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/completed-to-refunded')
  async transitionCompletedToRefunded(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Completed -> Refunded');
    const entity = await this.prisma.order.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Refunded');
      return await this.prisma.order.update({ where: { id: Number(id) }, data: { status: 'Refunded' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/refunded-to-completed')
  async transitionRefundedToCompleted(@Param('id') id: string) {
    throw new ConflictException('Transition Refunded -> Completed is not allowed');
  }

  @Patch(':id/transitions/completed-to-cancelled')
  async transitionCompletedToCancelled(@Param('id') id: string) {
    throw new ConflictException('Transition Completed -> Cancelled is not allowed');
  }
}
