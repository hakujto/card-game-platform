import { prisma } from '../../lib/prisma.js';

export class DraftSessionService {
  async findAll() {
    return prisma.draftSession.findMany();
  }

  async findOne(id: number) {
    return prisma.draftSession.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.draftSession.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.draftSession.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.draftSession.delete({ where: { id } });
  }

  async is_full(): Promise<boolean> {
    throw new Error('is_full not implemented');
  }
  async start(id: number): Promise<void> {
    const entity = await prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    // TODO: implement start domain logic
    throw new Error('start not implemented');
  }

  async abandon(id: number): Promise<void> {
    const entity = await prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    // TODO: implement abandon domain logic
    throw new Error('abandon not implemented');
  }

  async complete(id: number): Promise<void> {
    const entity = await prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    // TODO: implement complete domain logic
    throw new Error('complete not implemented');
  }
}
