import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class StreamService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.stream.findMany();
  }

  async findOne(id: number) {
    return this.prisma.stream.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.stream.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.stream.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.stream.delete({ where: { id } });
  }

  async go_live(id: number): Promise<void> {
    const entity = await this.prisma.stream.findUnique({ where: { id } });
    if (!entity) throw new Error('Stream not found: ' + id);
    // TODO: implement go_live domain logic
  }
  async end(id: number): Promise<void> {
    const entity = await this.prisma.stream.findUnique({ where: { id } });
    if (!entity) throw new Error('Stream not found: ' + id);
    // TODO: implement end domain logic
  }
  async update_viewer_peak(id: number, count: number): Promise<void> {
    const entity = await this.prisma.stream.findUnique({ where: { id } });
    if (!entity) throw new Error('Stream not found: ' + id);
    // TODO: implement update_viewer_peak domain logic
  }
  async duration_minutes(id: number): Promise<number> {
    const entity = await this.prisma.stream.findUnique({ where: { id } });
    if (!entity) throw new Error('Stream not found: ' + id);
    // TODO: implement duration_minutes domain logic
    return undefined as any;
  }
}
