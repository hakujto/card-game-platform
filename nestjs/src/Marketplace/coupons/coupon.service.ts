import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CouponService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.coupon.findMany();
  }

  async findOne(id: number) {
    return this.prisma.coupon.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.coupon.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.coupon.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.coupon.delete({ where: { id } });
  }

  async is_valid(id: number): Promise<boolean> {
    const entity = await this.prisma.coupon.findUnique({ where: { id } });
    if (!entity) throw new Error('Coupon not found: ' + id);
    // TODO: implement is_valid domain logic
    return undefined as any;
  }
  async is_applicable_to_order(id: number, orderTotal: number): Promise<boolean> {
    const entity = await this.prisma.coupon.findUnique({ where: { id } });
    if (!entity) throw new Error('Coupon not found: ' + id);
    // TODO: implement is_applicable_to_order domain logic
    return undefined as any;
  }
  async redeem(id: number): Promise<void> {
    const entity = await this.prisma.coupon.findUnique({ where: { id } });
    if (!entity) throw new Error('Coupon not found: ' + id);
    if (!(entity.isActive === true)) throw new Error('Guard condition not met for redeem');
    // TODO: implement redeem domain logic
  }
  async deactivate(id: number): Promise<void> {
    const entity = await this.prisma.coupon.findUnique({ where: { id } });
    if (!entity) throw new Error('Coupon not found: ' + id);
    // TODO: implement deactivate domain logic
  }
}
