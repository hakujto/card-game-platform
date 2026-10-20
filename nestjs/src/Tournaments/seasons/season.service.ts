import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class SeasonService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.season.findMany();
  }

  async findOne(id: number) {
    return this.prisma.season.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.season.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.season.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.season.delete({ where: { id } });
  }

  async activate(id: number): Promise<void> {
    const entity = await this.prisma.season.findUnique({ where: { id } });
    if (!entity) throw new Error('Season not found: ' + id);
    // TODO: implement activate domain logic
  }
  async deactivate(id: number): Promise<void> {
    const entity = await this.prisma.season.findUnique({ where: { id } });
    if (!entity) throw new Error('Season not found: ' + id);
    // TODO: implement deactivate domain logic
  }
  async finalize_rewards(id: number): Promise<void> {
    const entity = await this.prisma.season.findUnique({ where: { id } });
    if (!entity) throw new Error('Season not found: ' + id);
    // TODO: implement finalize_rewards domain logic
  }
  async is_ongoing(id: number): Promise<boolean> {
    const entity = await this.prisma.season.findUnique({ where: { id } });
    if (!entity) throw new Error('Season not found: ' + id);
    // TODO: implement is_ongoing domain logic
    return undefined as any;
  }
}
