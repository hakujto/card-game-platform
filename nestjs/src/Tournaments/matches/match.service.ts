import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class MatchService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.match.findMany();
  }

  async findOne(id: number) {
    return this.prisma.match.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.match.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.match.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.match.delete({ where: { id } });
  }

  async record_result(id: number, p1Wins: number, p2Wins: number): Promise<void> {
    const entity = await this.prisma.match.findUnique({ where: { id } });
    if (!entity) throw new Error('Match not found: ' + id);
    // TODO: implement record_result domain logic
    // TODO: await this.determineWinner(id); // @after
  }
  async finalize_result(id: number): Promise<void> {
    const entity = await this.prisma.match.findUnique({ where: { id } });
    if (!entity) throw new Error('Match not found: ' + id);
    // TODO: implement finalize_result domain logic
    // TODO: await this.determineWinner(id); // @after
  }
  async determine_winner(id: number): Promise<boolean> {
    const entity = await this.prisma.match.findUnique({ where: { id } });
    if (!entity) throw new Error('Match not found: ' + id);
    // TODO: implement determine_winner domain logic
    return undefined as any;
  }
  async concede(id: number, playerId: number): Promise<void> {
    const entity = await this.prisma.match.findUnique({ where: { id } });
    if (!entity) throw new Error('Match not found: ' + id);
    if (!(entity.status === 'ACTIVE')) throw new Error('Guard condition not met for concede');
    // TODO: implement concede domain logic
  }
  async draw(id: number): Promise<void> {
    const entity = await this.prisma.match.findUnique({ where: { id } });
    if (!entity) throw new Error('Match not found: ' + id);
    // TODO: implement draw domain logic
  }
}
