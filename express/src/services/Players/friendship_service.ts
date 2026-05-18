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

  async accept(id: number): Promise<void> {
    const entity = await prisma.friendship.findUnique({ where: { id } });
    if (!entity) throw new Error('Friendship not found: ' + id);
    // TODO: implement accept domain logic
    throw new Error('accept not implemented');
  }

  async decline(id: number): Promise<void> {
    const entity = await prisma.friendship.findUnique({ where: { id } });
    if (!entity) throw new Error('Friendship not found: ' + id);
    // TODO: implement decline domain logic
    throw new Error('decline not implemented');
  }

  async block(id: number): Promise<void> {
    const entity = await prisma.friendship.findUnique({ where: { id } });
    if (!entity) throw new Error('Friendship not found: ' + id);
    // TODO: implement block domain logic
    throw new Error('block not implemented');
  }
}
