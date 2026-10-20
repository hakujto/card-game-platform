import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class PlayerCollectionService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.playerCollection.findMany();
  }

  async findOne(id: number) {
    return this.prisma.playerCollection.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.playerCollection.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.playerCollection.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.playerCollection.delete({ where: { id } });
  }

  async add(id: number, quantity: number): Promise<void> {
    const entity = await this.prisma.playerCollection.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerCollection not found: ' + id);
    // TODO: implement add domain logic
  }
  async estimated_value(id: number): Promise<number> {
    const entity = await this.prisma.playerCollection.findUnique({ where: { id } });
    if (!entity) throw new Error('PlayerCollection not found: ' + id);
    // TODO: implement estimated_value domain logic
    return undefined as any;
  }
}
