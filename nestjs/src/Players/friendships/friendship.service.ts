import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class FriendshipService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.friendship.findMany();
  }

  async findOne(id: number) {
    return this.prisma.friendship.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.friendship.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.friendship.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.friendship.delete({ where: { id } });
  }

  async accept(id: number): Promise<void> {
    const entity = await this.prisma.friendship.findUnique({ where: { id } });
    if (!entity) throw new Error('Friendship not found: ' + id);
    // TODO: implement accept domain logic
  }
  async decline(id: number): Promise<void> {
    const entity = await this.prisma.friendship.findUnique({ where: { id } });
    if (!entity) throw new Error('Friendship not found: ' + id);
    // TODO: implement decline domain logic
  }
  async block(id: number): Promise<void> {
    const entity = await this.prisma.friendship.findUnique({ where: { id } });
    if (!entity) throw new Error('Friendship not found: ' + id);
    // TODO: implement block domain logic
  }
}
