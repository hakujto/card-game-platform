import { prisma } from '../../lib/prisma.js';

export class DraftParticipantService {
  async findAll() {
    return prisma.draftParticipant.findMany();
  }

  async findOne(id: number) {
    return prisma.draftParticipant.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.draftParticipant.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.draftParticipant.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.draftParticipant.delete({ where: { id } });
  }

  async drafted_card_count(): Promise<number> {
    throw new Error('drafted_card_count not implemented');
  }
  async pick_card(id: number, cardId: number, packNumber: number): Promise<void> {
    const entity = await prisma.draftParticipant.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftParticipant not found: ' + id);
    // TODO: implement pick_card domain logic
    throw new Error('pick_card not implemented');
  }
}
