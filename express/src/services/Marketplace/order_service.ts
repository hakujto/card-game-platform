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
}
