import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class TradeBidService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.tradeBid.findMany();
  }

  async findOne(id: number) {
    return this.prisma.tradeBid.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.tradeBid.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.tradeBid.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.tradeBid.delete({ where: { id } });
  }

  async outbid_by(id: number, newAmount: number): Promise<boolean> {
    const entity = await this.prisma.tradeBid.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeBid not found: ' + id);
    // TODO: implement outbid_by domain logic
    return undefined as any;
  }
  async retract(id: number): Promise<void> {
    const entity = await this.prisma.tradeBid.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeBid not found: ' + id);
    // TODO: implement retract domain logic
  }
}
