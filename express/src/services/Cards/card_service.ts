import { prisma } from '../../lib/prisma.js';

export class CardService {
  async findAll() {
    return prisma.card.findMany();
  }

  async findOne(id: number) {
    return prisma.card.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.card.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.card.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.card.delete({ where: { id } });
  }

  async ban(id: number): Promise<void> {
    const entity = await prisma.card.findUnique({ where: { id } });
    if (!entity) throw new Error('Card not found: ' + id);
    // TODO: implement ban domain logic
    throw new Error('ban not implemented');
  }

  async unban(id: number): Promise<void> {
    const entity = await prisma.card.findUnique({ where: { id } });
    if (!entity) throw new Error('Card not found: ' + id);
    // TODO: implement unban domain logic
    throw new Error('unban not implemented');
  }

  async restrict(id: number): Promise<void> {
    const entity = await prisma.card.findUnique({ where: { id } });
    if (!entity) throw new Error('Card not found: ' + id);
    // TODO: implement restrict domain logic
    throw new Error('restrict not implemented');
  }

  async unrestrict(id: number): Promise<void> {
    const entity = await prisma.card.findUnique({ where: { id } });
    if (!entity) throw new Error('Card not found: ' + id);
    // TODO: implement unrestrict domain logic
    throw new Error('unrestrict not implemented');
  }

  async calculate_value(id: number): Promise<number> {
    const entity = await prisma.card.findUnique({ where: { id } });
    if (!entity) throw new Error('Card not found: ' + id);
    // TODO: implement calculate_value domain logic
    throw new Error('calculate_value not implemented');
  }

  async apply_rarity_bonus(id: number, multiplier: number): Promise<number> {
    const entity = await prisma.card.findUnique({ where: { id } });
    if (!entity) throw new Error('Card not found: ' + id);
    // TODO: implement apply_rarity_bonus domain logic
    throw new Error('apply_rarity_bonus not implemented');
  }

  async is_legal_in_format(id: number, format: string): Promise<boolean> {
    const entity = await prisma.card.findUnique({ where: { id } });
    if (!entity) throw new Error('Card not found: ' + id);
    // TODO: implement is_legal_in_format domain logic
    throw new Error('is_legal_in_format not implemented');
  }
}
