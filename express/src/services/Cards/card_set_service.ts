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

  async is_legal_in_standard(): Promise<boolean> {
    throw new Error('is_legal_in_standard not implemented');
  }
}
