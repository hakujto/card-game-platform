import { prisma } from '../../lib/prisma.js';

export class OrderService {
  async findAll() {
    return prisma.order.findMany();
  }

  async findOne(id: number) {
    return prisma.order.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.order.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.order.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.order.delete({ where: { id } });
  }

  async cancel(id: number): Promise<void> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    // TODO: implement cancel domain logic
    throw new Error('cancel not implemented');
  }

  async pay(id: number, paymentRef: string): Promise<boolean> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    // TODO: implement pay domain logic
    throw new Error('pay not implemented');
  }

  async calculate_total(id: number): Promise<number> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    // TODO: implement calculate_total domain logic
    throw new Error('calculate_total not implemented');
  }

  async apply_discount(id: number, percent: number): Promise<number> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    // TODO: implement apply_discount domain logic
    throw new Error('apply_discount not implemented');
  }

  async refund(id: number): Promise<void> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    // TODO: implement refund domain logic
    throw new Error('refund not implemented');
  }

  // triggered by @on(status = Shipped)
  async setStatus(id: number, value: string): Promise<void> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    await prisma.order.update({ where: { id }, data: { status: value as any } });
    if (value === 'SHIPPED') {
      // TODO: call entity.notify_shipped() after implementing domain model
    }
  }
}
