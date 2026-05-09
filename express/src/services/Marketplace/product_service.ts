import { prisma } from '../../lib/prisma.js';

export class ProductService {
  async findAll() {
    return prisma.product.findMany();
  }

  async findOne(id: number) {
    return prisma.product.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.product.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.product.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.product.delete({ where: { id } });
  }
}
