import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class OrderItemService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.orderItem.findMany();
  }

  async findOne(id: number) {
    return this.prisma.orderItem.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.orderItem.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.orderItem.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.orderItem.delete({ where: { id } });
  }

  async line_total(id: number): Promise<number> {
    const entity = await this.prisma.orderItem.findUnique({ where: { id } });
    if (!entity) throw new Error('OrderItem not found: ' + id);
    // TODO: implement line_total domain logic
    return undefined as any;
  }
}
