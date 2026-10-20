import { BadRequestException, Body, Controller, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { PlayerAchievementService } from './player_achievement.service';


function validate(data: any): void {
  if (!((data.progress == null || data.progress >= 0))) throw new Error(`Achievement progress must not be negative`);
  if ((data.isCompleted === true) && !((data.progress == null || data.progress > 0))) throw new Error(`Completed achievement must have progress greater than zero`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('earnedAt' in r) { r.earnedAt = r.earnedAt; delete r.earnedAt; }
  return r;
}

@Controller('player_achievements')
export class PlayerAchievementController {
  constructor(private readonly prisma: PrismaService, private readonly playerAchievementService: PlayerAchievementService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.playerAchievement.findMany();
    return items.map(applyProjection);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.playerAchievement.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Patch('/:id/progress')
  @HttpCode(204)
  async increment_progress(@Param('id') id: string, @Body() body: any) {
    try {
      await this.playerAchievementService.increment_progress(Number(id), body.amount);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/complete')
  @HttpCode(204)
  async complete(@Param('id') id: string) {
    try {
      await this.playerAchievementService.complete(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
