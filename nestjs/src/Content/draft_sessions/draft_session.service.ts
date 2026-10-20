import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class DraftSessionService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.draftSession.findMany();
  }

  async findOne(id: number) {
    return this.prisma.draftSession.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.draftSession.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.draftSession.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.draftSession.delete({ where: { id } });
  }

  async start(id: number): Promise<void> {
    const entity = await this.prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    // TODO: implement start domain logic
  }
  async abandon(id: number): Promise<void> {
    const entity = await this.prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    // TODO: implement abandon domain logic
  }
  async complete(id: number): Promise<void> {
    const entity = await this.prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    // TODO: implement complete domain logic
  }
  async is_full(id: number): Promise<boolean> {
    const entity = await this.prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    // TODO: implement is_full domain logic
    return undefined as any;
  }
}
