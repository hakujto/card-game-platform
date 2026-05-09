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
}
