import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class DraftPickService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.draftPick.findMany();
  }

  async findOne(id: number) {
    return this.prisma.draftPick.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.draftPick.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.draftPick.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.draftPick.delete({ where: { id } });
  }

  async is_first_pick(id: number): Promise<boolean> {
    const entity = await this.prisma.draftPick.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftPick not found: ' + id);
    // TODO: implement is_first_pick domain logic
    return undefined as any;
  }
}
