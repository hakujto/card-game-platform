import { BadRequestException, Body, ConflictException, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TradeListingService } from './trade_listing.service';


function validate(data: any): void {
  if ((data.listingType === 'FixedPrice') && data.askingPrice == null) throw new Error('asking_price is required');
  if (!((data.quantity == null || (data.quantity >= 1 && data.quantity <= 9999)))) throw new Error(`Listing quantity must be between 1 and 9999`);
  if ((data.listingType === 'FIXEDPRICE') && !((data.askingPrice === undefined || data.askingPrice != null))) throw new Error(`Fixed price listing must have an asking price`);
  if ((data.listingType === 'AUCTION') && !((data.auctionStartPrice === undefined || data.auctionStartPrice != null) && (data.auctionEndTime === undefined || data.auctionEndTime != null))) throw new Error(`Auction listing must have a start price and end time`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('expiresAt' in r) { r.expiresAt = r.expiresAt; delete r.expiresAt; }
  if ('auctionEndTime' in r) { r.auctionEndTime = r.auctionEndTime; delete r.auctionEndTime; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Pending': ['Active'],
  'Active': ['Sold', 'Expired', 'Cancelled']
};
function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

@Controller('trade_listings')
export class TradeListingController {
  constructor(private readonly prisma: PrismaService, private readonly tradeListingService: TradeListingService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ description: { contains: q } }] } : undefined;
    const items = await this.prisma.tradeListing.findMany(where ? { where } : undefined);
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.publicId !== undefined) data.publicId = body.publicId;
    if (body.status !== undefined) data.status = body.status;
    if (body.listingType !== undefined) data.listingType = body.listingType;
    if (body.askingPrice !== undefined) data.askingPrice = body.askingPrice;
    if (body.auctionStartPrice !== undefined) data.auctionStartPrice = body.auctionStartPrice;
    if (body.auctionCurrentBid !== undefined) data.auctionCurrentBid = body.auctionCurrentBid;
    if (body.auctionEndTime !== undefined) data.auctionEndTime = body.auctionEndTime != null ? new Date(body.auctionEndTime) : null;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.description !== undefined) data.description = body.description;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.expiresAt !== undefined) data.expiresAt = body.expiresAt != null ? new Date(body.expiresAt) : null;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
    validate(data);
      const entity = await this.prisma.tradeListing.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.tradeListing.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.publicId !== undefined) data.publicId = body.publicId;
    if (body.listingType !== undefined) data.listingType = body.listingType;
    if (body.askingPrice !== undefined) data.askingPrice = body.askingPrice;
    if (body.auctionStartPrice !== undefined) data.auctionStartPrice = body.auctionStartPrice;
    if (body.auctionCurrentBid !== undefined) data.auctionCurrentBid = body.auctionCurrentBid;
    if (body.auctionEndTime !== undefined) data.auctionEndTime = body.auctionEndTime != null ? new Date(body.auctionEndTime) : null;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.description !== undefined) data.description = body.description;
    if (body.expiresAt !== undefined) data.expiresAt = body.expiresAt != null ? new Date(body.expiresAt) : null;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
    validate(data);
      const existing = await this.prisma.tradeListing.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.tradeListing.update({ where: { id: Number(id) }, data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Post('/:id/close')
  @HttpCode(204)
  async close(@Param('id') id: string) {
    try {
      await this.tradeListingService.close(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch('/:id/extend')
  @HttpCode(204)
  async extend(@Param('id') id: string, @Body() body: any) {
    try {
      await this.tradeListingService.extend(Number(id), body.days);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Delete('/:id/cancel')
  @HttpCode(204)
  async cancel(@Param('id') id: string) {
    try {
      await this.tradeListingService.cancel(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/expired')
  async is_expired(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.tradeListingService.is_expired(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/finalize')
  @HttpCode(204)
  async finalize_auction(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['admin', 'seller'].includes(userRole)) throw new ForbiddenException('Insufficient role for finalize_auction');
    try {
      await this.tradeListingService.finalize_auction(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }


  @Patch(':id/transitions/pending-to-active')
  async transitionPendingToActive(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Seller'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Pending -> Active');
    const entity = await this.prisma.tradeListing.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Active');
      if ((entity as any).quantity == null) throw new Error('quantity is required for Pending -> Active');
      return await this.prisma.tradeListing.update({ where: { id: Number(id) }, data: { status: 'Active' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/active-to-sold')
  async transitionActiveToSold(@Param('id') id: string) {
    const entity = await this.prisma.tradeListing.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Sold');
      return await this.prisma.tradeListing.update({ where: { id: Number(id) }, data: { status: 'Sold' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/active-to-expired')
  async transitionActiveToExpired(@Param('id') id: string) {
    const entity = await this.prisma.tradeListing.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Expired');
      return await this.prisma.tradeListing.update({ where: { id: Number(id) }, data: { status: 'Expired' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/active-to-cancelled')
  async transitionActiveToCancelled(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['Seller', 'Admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for transition Active -> Cancelled');
    const entity = await this.prisma.tradeListing.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    try {
      assertTransition((entity as any).status, 'Cancelled');
      return await this.prisma.tradeListing.update({ where: { id: Number(id) }, data: { status: 'Cancelled' as any } });
    } catch (err: any) {
      const msg = err?.message ?? 'Error';
      if (msg.includes('not allowed')) throw new ConflictException(msg);
      if (msg.includes('required') || msg.includes('must be')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch(':id/transitions/sold-to-active')
  async transitionSoldToActive(@Param('id') id: string) {
    throw new ConflictException('Transition Sold -> Active is not allowed');
  }

  @Patch(':id/transitions/expired-to-active')
  async transitionExpiredToActive(@Param('id') id: string) {
    throw new ConflictException('Transition Expired -> Active is not allowed');
  }
}
