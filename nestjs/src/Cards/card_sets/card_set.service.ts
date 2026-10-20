import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CardSetService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.cardSet.findMany();
  }

  async findOne(id: number) {
    return this.prisma.cardSet.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.cardSet.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.cardSet.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.cardSet.delete({ where: { id } });
  }

  async is_legal_in_standard(id: number): Promise<boolean> {
    const entity = await this.prisma.cardSet.findUnique({ where: { id } });
    if (!entity) throw new Error('CardSet not found: ' + id);
    // TODO: implement is_legal_in_standard domain logic
    return undefined as any;
  }
  async is_legal_in_format(id: number, format: string): Promise<boolean> {
    const entity = await this.prisma.cardSet.findUnique({ where: { id } });
    if (!entity) throw new Error('CardSet not found: ' + id);
    // TODO: implement is_legal_in_format domain logic
    return undefined as any;
  }
  async card_count_by_rarity(id: number, rarity: string): Promise<number> {
    const entity = await this.prisma.cardSet.findUnique({ where: { id } });
    if (!entity) throw new Error('CardSet not found: ' + id);
    // TODO: implement card_count_by_rarity domain logic
    return undefined as any;
  }
  async rotate_out(id: number): Promise<void> {
    const entity = await this.prisma.cardSet.findUnique({ where: { id } });
    if (!entity) throw new Error('CardSet not found: ' + id);
    // TODO: implement rotate_out domain logic
  }
}
