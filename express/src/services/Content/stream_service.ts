import { prisma } from '../../lib/prisma.js';

export class StreamService {
  async findAll() {
    return prisma.stream.findMany();
  }

  async findOne(id: number) {
    return prisma.stream.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.stream.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.stream.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.stream.delete({ where: { id } });
  }
}
