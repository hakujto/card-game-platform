import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class DeckTagService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.deckTag.findMany();
  }

  async findOne(id: number) {
    return this.prisma.deckTag.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.deckTag.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.deckTag.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.deckTag.delete({ where: { id } });
  }

  async rename(id: number, newName: string): Promise<void> {
    const entity = await this.prisma.deckTag.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckTag not found: ' + id);
    // TODO: implement rename domain logic
  }
  async merge_into(id: number, targetTagId: number): Promise<void> {
    const entity = await this.prisma.deckTag.findUnique({ where: { id } });
    if (!entity) throw new Error('DeckTag not found: ' + id);
    // TODO: implement merge_into domain logic
  }
}
