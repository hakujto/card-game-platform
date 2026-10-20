import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class TournamentJudgeService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.tournamentJudge.findMany();
  }

  async findOne(id: number) {
    return this.prisma.tournamentJudge.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.tournamentJudge.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.tournamentJudge.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.tournamentJudge.delete({ where: { id } });
  }

  async promote_to_head(id: number): Promise<void> {
    const entity = await this.prisma.tournamentJudge.findUnique({ where: { id } });
    if (!entity) throw new Error('TournamentJudge not found: ' + id);
    // TODO: implement promote_to_head domain logic
  }
}
