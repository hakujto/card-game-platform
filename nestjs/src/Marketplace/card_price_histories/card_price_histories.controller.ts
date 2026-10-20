import { BadRequestException, Body, Controller, Get, HttpCode, NotFoundException, Param, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CardPriceHistoryService } from './card_price_history.service';


function validate(data: any): void {
  if (!(((data.minPrice == null || (data.avgPrice != null && Number(data.minPrice) <= Number(data.avgPrice))) && (data.avgPrice == null || (data.maxPrice != null && Number(data.avgPrice) <= Number(data.maxPrice)))))) throw new Error(`min_price <= avg_price <= max_price must hold`);
  if (!((data.volume == null || data.volume >= 0))) throw new Error(`Price history volume must not be negative`);
  if (!((data.minPrice == null || Number(data.minPrice) >= 0))) throw new Error(`Prices must not be negative`);
}

@Controller('card_price_histories')
export class CardPriceHistoryController {
  constructor(private readonly prisma: PrismaService, private readonly cardPriceHistoryService: CardPriceHistoryService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.cardPriceHistory.findMany();
    return items;
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.cardPriceHistory.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Get('/:id/change')
  async price_change_percent(@Param('id') id: string, @Query('previousAvg') previousAvg: any) {
    let result: any;
    try {
      result = await this.cardPriceHistoryService.price_change_percent(Number(id), previousAvg);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Get('/:id/spike')
  async is_price_spike(@Param('id') id: string, @Query('thresholdPercent') thresholdPercent: any) {
    let result: any;
    try {
      result = await this.cardPriceHistoryService.is_price_spike(Number(id), thresholdPercent);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
