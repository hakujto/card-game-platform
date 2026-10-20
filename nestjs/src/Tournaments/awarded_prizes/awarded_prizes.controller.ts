import { BadRequestException, Body, Controller, Get, HttpCode, NotFoundException, Param, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { AwardedPrizeService } from './awarded_prize.service';


function validate(data: any): void {
  if ((data.claimed === true) && data.claimedAt == null) throw new Error('claimed_at is required');
  if (!((data.finalPlacement == null || data.finalPlacement > 0))) throw new Error(`Final placement must be greater than zero`);
  if ((data.claimed === true) && !((data.claimedAt === undefined || data.claimedAt != null))) throw new Error(`Claimed prize must have a claimed_at timestamp`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('awardedAt' in r) { r.awardedAt = r.awardedAt; delete r.awardedAt; }
  if ('claimedAt' in r) { r.claimedAt = r.claimedAt; delete r.claimedAt; }
  return r;
}

@Controller('awarded_prizes')
export class AwardedPrizeController {
  constructor(private readonly prisma: PrismaService, private readonly awardedPrizeService: AwardedPrizeService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.awardedPrize.findMany();
    return items.map(applyProjection);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.awardedPrize.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Post('/:id/claim')
  @HttpCode(204)
  async claim(@Param('id') id: string) {
    try {
      await this.awardedPrizeService.claim(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
