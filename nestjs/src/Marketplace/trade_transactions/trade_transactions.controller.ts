import { BadRequestException, Body, Controller, Get, HttpCode, NotFoundException, Param, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TradeTransactionService } from './trade_transaction.service';


function validate(data: any): void {
  if ((data.status === 'Completed') && data.completedAt == null) throw new Error('completed_at is required');
  if (!((data.platformFee == null || (data.finalPrice != null && Number(data.platformFee) <= Number(data.finalPrice))))) throw new Error(`Platform fee cannot exceed the final price`);
  if (!((data.platformFee == null || Number(data.platformFee) >= 0))) throw new Error(`Platform fee must not be negative`);
  if (!((data.finalPrice == null || Number(data.finalPrice) > 0))) throw new Error(`Transaction final price must be greater than zero`);
  if ((data.status === 'COMPLETED') && !((data.completedAt === undefined || data.completedAt != null))) throw new Error(`Completed transaction must have a completed_at timestamp`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('completedAt' in r) { r.completedAt = r.completedAt; delete r.completedAt; }
  return r;
}

@Controller('trade_transactions')
export class TradeTransactionController {
  constructor(private readonly prisma: PrismaService, private readonly tradeTransactionService: TradeTransactionService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.tradeTransaction.findMany();
    return items.map(applyProjection);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.tradeTransaction.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Post('/:id/complete')
  @HttpCode(204)
  async complete(@Param('id') id: string) {
    try {
      await this.tradeTransactionService.complete(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/refund')
  @HttpCode(204)
  async refund(@Param('id') id: string) {
    try {
      await this.tradeTransactionService.refund(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/dispute')
  @HttpCode(204)
  async open_dispute(@Param('id') id: string, @Body() body: any) {
    try {
      await this.tradeTransactionService.open_dispute(Number(id), body.reason);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/seller-net')
  async seller_net(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.tradeTransactionService.seller_net(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
