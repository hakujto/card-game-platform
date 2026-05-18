import { prisma } from '../../lib/prisma.js';

export class TradelistingService {
  async findAll() {
    return prisma.tradelisting.findMany();
  }

  async findOne(id: number) {
    return prisma.tradelisting.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tradelisting.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tradelisting.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tradelisting.delete({ where: { id } });
  }

  async is_expired(): Promise<boolean> {
    throw new Error('is_expired not implemented');
  }
  async close(id: number): Promise<void> {
    const entity = await prisma.tradelisting.findUnique({ where: { id } });
    if (!entity) throw new Error('Tradelisting not found: ' + id);
    // TODO: implement close domain logic
    throw new Error('close not implemented');
  }

  async extend(id: number, days: number): Promise<void> {
    const entity = await prisma.tradelisting.findUnique({ where: { id } });
    if (!entity) throw new Error('Tradelisting not found: ' + id);
    // TODO: implement extend domain logic
    throw new Error('extend not implemented');
  }

  async cancel(id: number): Promise<void> {
    const entity = await prisma.tradelisting.findUnique({ where: { id } });
    if (!entity) throw new Error('Tradelisting not found: ' + id);
    // TODO: implement cancel domain logic
    throw new Error('cancel not implemented');
  }

  // triggered by @on(status = Sold)
  async setStatus(id: number, value: string): Promise<void> {
    const entity = await prisma.tradelisting.findUnique({ where: { id } });
    if (!entity) throw new Error('Tradelisting not found: ' + id);
    await prisma.tradelisting.update({ where: { id }, data: { status: value as any } });
    if (value === 'SOLD') {
      // TODO: call entity.finalize_auction() after implementing domain model
    }
  }
}
