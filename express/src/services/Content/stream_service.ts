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

  async duration_minutes(): Promise<number> {
    throw new Error('duration_minutes not implemented');
  }
  async go_live(id: number): Promise<void> {
    const entity = await prisma.stream.findUnique({ where: { id } });
    if (!entity) throw new Error('Stream not found: ' + id);
    // TODO: implement go_live domain logic
    throw new Error('go_live not implemented');
  }

  async end(id: number): Promise<void> {
    const entity = await prisma.stream.findUnique({ where: { id } });
    if (!entity) throw new Error('Stream not found: ' + id);
    // TODO: implement end domain logic
    throw new Error('end not implemented');
  }

  async update_viewer_peak(id: number, count: number): Promise<void> {
    const entity = await prisma.stream.findUnique({ where: { id } });
    if (!entity) throw new Error('Stream not found: ' + id);
    // TODO: implement update_viewer_peak domain logic
    throw new Error('update_viewer_peak not implemented');
  }
}
