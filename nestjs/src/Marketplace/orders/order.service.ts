import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class OrderService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.order.findMany();
  }

  async findOne(id: number) {
    return this.prisma.order.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.order.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.order.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.order.delete({ where: { id } });
  }

  async cancel(id: number): Promise<void> {
    const entity = await this.prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    // TODO: implement cancel domain logic
  }
  async pay(id: number, paymentRef: string): Promise<boolean> {
    const entity = await this.prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    if (!(entity.status === 'PENDING')) throw new Error('Guard condition not met for pay');
    // TODO: implement pay domain logic
    return undefined as any;
  }
  async process_payment(id: number): Promise<boolean> {
    const entity = await this.prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    // TODO: implement process_payment domain logic
    return undefined as any;
  }
  async calculate_total(id: number): Promise<number> {
    const entity = await this.prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    // TODO: implement calculate_total domain logic
    return undefined as any;
  }
  async apply_discount(id: number, percent: number): Promise<number> {
    const entity = await this.prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    // TODO: implement apply_discount domain logic
    return undefined as any;
  }
  async refund(id: number): Promise<void> {
    const entity = await this.prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    // TODO: implement refund domain logic
  }
  // triggered by @on(status = Shipped)
  async setStatus(id: number, value: string): Promise<void> {
    const entity = await this.prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    await this.prisma.order.update({ where: { id }, data: { status: value as any } });
  }
  // ── Lifecycle hooks ──────────────────────────────────────────────

  async assignCurrencyDefault(entity: any): Promise<void> {
    // TODO: implement assign_currency_default
  }

  async notifyStatusChange(entity: any): Promise<void> {
    // TODO: implement notify_status_change
  }
  emitOrderPaid(orderId: number, playerId: number, total: number, paymentMethod: string, paidAt: string): void {
    // TODO: emit OrderPaid event
  }

  emitOrderShipped(orderId: number, trackingNumber: string, shippedAt: string): void {
    // TODO: emit OrderShipped event
  }

  emitOrderRefunded(orderId: number, refundedAt: string): void {
    // TODO: emit OrderRefunded event
  }
}
