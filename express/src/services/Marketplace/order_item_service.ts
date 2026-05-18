import { prisma } from '../../lib/prisma.js';

export class OrderItemService {
  async findAll() {
    return prisma.orderItem.findMany();
  }

  async findOne(id: number) {
    return prisma.orderItem.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.orderItem.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.orderItem.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.orderItem.delete({ where: { id } });
  }

  async line_total(id: number): Promise<number> {
    const entity = await prisma.orderItem.findUnique({ where: { id } });
    if (!entity) throw new Error('OrderItem not found: ' + id);
    // TODO: implement line_total domain logic
    throw new Error('line_total not implemented');
  }
}
