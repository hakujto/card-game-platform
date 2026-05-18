import { prisma } from '../../lib/prisma.js';

export class CouponService {
  async findAll() {
    return prisma.coupon.findMany();
  }

  async findOne(id: number) {
    return prisma.coupon.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.coupon.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.coupon.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.coupon.delete({ where: { id } });
  }

  async is_valid(): Promise<boolean> {
    throw new Error('is_valid not implemented');
  }

  async is_applicable_to_order(orderTotal: number): Promise<boolean> {
    throw new Error('is_applicable_to_order not implemented');
  }
  async redeem(id: number): Promise<void> {
    const entity = await prisma.coupon.findUnique({ where: { id } });
    if (!entity) throw new Error('Coupon not found: ' + id);
    // TODO: implement redeem domain logic
    throw new Error('redeem not implemented');
  }

  async deactivate(id: number): Promise<void> {
    const entity = await prisma.coupon.findUnique({ where: { id } });
    if (!entity) throw new Error('Coupon not found: ' + id);
    // TODO: implement deactivate domain logic
    throw new Error('deactivate not implemented');
  }
}
