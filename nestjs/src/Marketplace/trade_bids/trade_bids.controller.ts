import { BadRequestException, Body, Controller, Delete, Get, HttpCode, NotFoundException, Param, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TradeBidService } from './trade_bid.service';


function validate(data: any): void {
  if (!((data.amount == null || Number(data.amount) > 0))) throw new Error(`Bid amount must be greater than zero`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('placedAt' in r) { r.placedAt = r.placedAt; delete r.placedAt; }
  return r;
}

@Controller('trade_bids')
export class TradeBidController {
  constructor(private readonly prisma: PrismaService, private readonly tradeBidService: TradeBidService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.tradeBid.findMany();
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.placedAt !== undefined) data.placedAt = body.placedAt != null ? new Date(body.placedAt) : null;
    if (body.isWinning !== undefined) data.isWinning = body.isWinning;
    if (body.listingId !== undefined) data.listingId = body.listingId;
    if (body.bidderId !== undefined) data.bidderId = body.bidderId;
    try {
    validate(data);
      const entity = await this.prisma.tradeBid.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.tradeBid.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Get('/:id/outbid')
  async outbid_by(@Param('id') id: string, @Query('newAmount') newAmount: any) {
    let result: any;
    try {
      result = await this.tradeBidService.outbid_by(Number(id), newAmount);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Delete('/:id')
  @HttpCode(204)
  async retract(@Param('id') id: string) {
    try {
      await this.tradeBidService.retract(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
