import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class DeckSideboardCardService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.deckSideboardCard.findMany();
  }

  async findOne(id: number) {
    return this.prisma.deckSideboardCard.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.deckSideboardCard.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.deckSideboardCard.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.deckSideboardCard.delete({ where: { id } });
  }

  async increment(id: number, amount: number): Promise<void> {
    const entity = await this.prisma.deckSideboardCard.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckSideboardCard not found: ' + id);
    // TODO: implement increment domain logic
  }
  async decrement(id: number, amount: number): Promise<void> {
    const entity = await this.prisma.deckSideboardCard.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckSideboardCard not found: ' + id);
    // TODO: implement decrement domain logic
  }
}
