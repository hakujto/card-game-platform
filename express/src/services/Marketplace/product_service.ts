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

  async activate(id: number): Promise<void> {
    const entity = await prisma.product.findUnique({ where: { id } });
    if (!entity) throw new Error('Product not found: ' + id);
    // TODO: implement activate domain logic
    throw new Error('activate not implemented');
  }

  async deactivate(id: number): Promise<void> {
    const entity = await prisma.product.findUnique({ where: { id } });
    if (!entity) throw new Error('Product not found: ' + id);
    // TODO: implement deactivate domain logic
    throw new Error('deactivate not implemented');
  }

  async apply_discount(id: number, percent: number): Promise<number> {
    const entity = await prisma.product.findUnique({ where: { id } });
    if (!entity) throw new Error('Product not found: ' + id);
    // TODO: implement apply_discount domain logic
    throw new Error('apply_discount not implemented');
  }

  async restock(id: number, quantity: number): Promise<void> {
    const entity = await prisma.product.findUnique({ where: { id } });
    if (!entity) throw new Error('Product not found: ' + id);
    // TODO: implement restock domain logic
    throw new Error('restock not implemented');
  }

  async effective_price(id: number): Promise<number> {
    const entity = await prisma.product.findUnique({ where: { id } });
    if (!entity) throw new Error('Product not found: ' + id);
    // TODO: implement effective_price domain logic
    throw new Error('effective_price not implemented');
  }

  async is_in_stock(id: number): Promise<boolean> {
    const entity = await prisma.product.findUnique({ where: { id } });
    if (!entity) throw new Error('Product not found: ' + id);
    // TODO: implement is_in_stock domain logic
    throw new Error('is_in_stock not implemented');
  }
}
