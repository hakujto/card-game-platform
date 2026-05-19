import { prisma } from '../../lib/prisma.js';

export class TradeListingService {
  async findAll() {
    return prisma.tradeListing.findMany();
  }

  async findOne(id: number) {
    return prisma.tradeListing.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tradeListing.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tradeListing.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tradeListing.delete({ where: { id } });
  }

  async close(id: number): Promise<void> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    // TODO: implement close domain logic
  }

  async extend(id: number, days: number): Promise<void> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    // TODO: implement extend domain logic
  }

  async cancel(id: number): Promise<void> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    // TODO: implement cancel domain logic
  }

  async is_expired(id: number): Promise<boolean> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    // TODO: implement is_expired domain logic
    return undefined as any;
  }

  async finalize_auction(id: number): Promise<void> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    // TODO: implement finalize_auction domain logic
  }

  // triggered by @on(status = Sold)
  async setStatus(id: number, value: string): Promise<void> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    await prisma.tradeListing.update({ where: { id }, data: { status: value as any } });
    if (value === 'SOLD') {
      // TODO: call entity.finalize_auction() after implementing domain model
    }
  }
}
