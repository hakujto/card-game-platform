import { prisma } from '../../lib/prisma.js';

export class FriendshipService {
  async findAll() {
    return prisma.friendship.findMany();
  }

  async findOne(id: number) {
    return prisma.friendship.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.friendship.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.friendship.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.friendship.delete({ where: { id } });
  }
}
