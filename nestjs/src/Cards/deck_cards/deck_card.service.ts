import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class DeckCardService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.deckCard.findMany();
  }

  async findOne(id: number) {
    return this.prisma.deckCard.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.deckCard.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.deckCard.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.deckCard.delete({ where: { id } });
  }

  async increment(id: number, amount: number): Promise<void> {
    const entity = await this.prisma.deckCard.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckCard not found: ' + id);
    // TODO: implement increment domain logic
  }
  async decrement(id: number, amount: number): Promise<void> {
    const entity = await this.prisma.deckCard.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckCard not found: ' + id);
    // TODO: implement decrement domain logic
  }
}
