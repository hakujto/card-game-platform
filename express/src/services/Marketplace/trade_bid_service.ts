import { prisma } from '../../lib/prisma.js';

export class TradeBidService {
  async findAll() {
    return prisma.tradeBid.findMany();
  }

  async findOne(id: number) {
    return prisma.tradeBid.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.tradeBid.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.tradeBid.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.tradeBid.delete({ where: { id } });
  }

  async outbid_by(id: number, newAmount: number): Promise<boolean> {
    const entity = await prisma.tradeBid.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeBid not found: ' + id);
    // TODO: implement outbid_by domain logic
    throw new Error('outbid_by not implemented');
  }

  async retract(id: number): Promise<void> {
    const entity = await prisma.tradeBid.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeBid not found: ' + id);
    // TODO: implement retract domain logic
    throw new Error('retract not implemented');
  }
}
