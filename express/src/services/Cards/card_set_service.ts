import { prisma } from '../../lib/prisma.js';

export class CardSetService {
  async findAll() {
    return prisma.cardSet.findMany();
  }

  async findOne(id: number) {
    return prisma.cardSet.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.cardSet.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.cardSet.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.cardSet.delete({ where: { id } });
  }

  async is_legal_in_standard(id: number): Promise<boolean> {
    const entity = await prisma.cardSet.findUnique({ where: { id } });
    if (!entity) throw new Error('CardSet not found: ' + id);
    // TODO: implement is_legal_in_standard domain logic
    throw new Error('is_legal_in_standard not implemented');
  }

  async is_legal_in_format(id: number, format: string): Promise<boolean> {
    const entity = await prisma.cardSet.findUnique({ where: { id } });
    if (!entity) throw new Error('CardSet not found: ' + id);
    // TODO: implement is_legal_in_format domain logic
    throw new Error('is_legal_in_format not implemented');
  }

  async card_count_by_rarity(id: number, rarity: string): Promise<number> {
    const entity = await prisma.cardSet.findUnique({ where: { id } });
    if (!entity) throw new Error('CardSet not found: ' + id);
    // TODO: implement card_count_by_rarity domain logic
    throw new Error('card_count_by_rarity not implemented');
  }

  async rotate_out(id: number): Promise<void> {
    const entity = await prisma.cardSet.findUnique({ where: { id } });
    if (!entity) throw new Error('CardSet not found: ' + id);
    // TODO: implement rotate_out domain logic
    throw new Error('rotate_out not implemented');
  }
}
