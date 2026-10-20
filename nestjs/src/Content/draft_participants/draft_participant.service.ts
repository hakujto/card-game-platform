import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class DraftParticipantService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.draftParticipant.findMany();
  }

  async findOne(id: number) {
    return this.prisma.draftParticipant.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.draftParticipant.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.draftParticipant.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.draftParticipant.delete({ where: { id } });
  }

  async pick_card(id: number, cardId: number, packNumber: number): Promise<void> {
    const entity = await this.prisma.draftParticipant.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftParticipant not found: ' + id);
    // TODO: implement pick_card domain logic
  }
  async drafted_card_count(id: number): Promise<number> {
    const entity = await this.prisma.draftParticipant.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftParticipant not found: ' + id);
    // TODO: implement drafted_card_count domain logic
    return undefined as any;
  }
}
