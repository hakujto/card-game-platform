import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class GameService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.game.findMany();
  }

  async findOne(id: number) {
    return this.prisma.game.findUnique({ where: { id } });
  }

  async create(data: any) {
    return this.prisma.game.create({ data });
  }

  async update(id: number, data: any) {
    return this.prisma.game.update({ where: { id }, data });
  }

  async remove(id: number) {
    return this.prisma.game.delete({ where: { id } });
  }

  async record_winner(id: number, winnerSide: string): Promise<void> {
    const entity = await this.prisma.game.findUnique({ where: { id } });
    if (!entity) throw new Error('Game not found: ' + id);
    // TODO: implement record_winner domain logic
  }
  async duration_minutes(id: number): Promise<number> {
    const entity = await this.prisma.game.findUnique({ where: { id } });
    if (!entity) throw new Error('Game not found: ' + id);
    // TODO: implement duration_minutes domain logic
    return undefined as any;
  }
}
