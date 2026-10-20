import { BadRequestException, Body, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CouponService } from './coupon.service';


function validate(data: any): void {
  if (data.discountValue != null && Number(data.discountValue) < 0.01) throw new Error('discount_value: must be >= 0.01');
  if (!((data.validUntil == null || (data.validFrom != null && data.validUntil > data.validFrom)))) throw new Error(`Coupon expiry must be after its start date`);
  if (!((data.discountValue == null || Number(data.discountValue) > 0))) throw new Error(`Discount value must be greater than zero`);
  if ((data.discountType === 'PERCENT') && !((data.discountValue == null || (data.discountValue >= 1 && data.discountValue <= 100)))) throw new Error(`Percent discount must be between 1 and 100`);
  if ((data.maxUses != null) && !((data.usesCount == null || (data.maxUses != null && data.usesCount <= data.maxUses)))) throw new Error(`Coupon uses count cannot exceed max_uses`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  delete r.usesCount;
  delete r.maxUses;
  return r;
}

@Controller('coupons')
export class CouponController {
  constructor(private readonly prisma: PrismaService, private readonly couponService: CouponService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ code: { contains: q } }] } : undefined;
    const items = await this.prisma.coupon.findMany(where ? { where } : undefined);
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.code !== undefined) data.code = body.code;
    if (body.discountType !== undefined) data.discountType = body.discountType;
    if (body.discountValue !== undefined) data.discountValue = body.discountValue;
    if (body.minOrderValue !== undefined) data.minOrderValue = body.minOrderValue;
    if (body.maxUses !== undefined) data.maxUses = body.maxUses;
    if (body.usesCount !== undefined) data.usesCount = body.usesCount;
    if (body.validFrom !== undefined) data.validFrom = body.validFrom != null ? new Date(body.validFrom) : null;
    if (body.validUntil !== undefined) data.validUntil = body.validUntil != null ? new Date(body.validUntil) : null;
    if (body.isActive !== undefined) data.isActive = body.isActive;
    try {
    validate(data);
      const entity = await this.prisma.coupon.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.coupon.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.code !== undefined) data.code = body.code;
    if (body.discountType !== undefined) data.discountType = body.discountType;
    if (body.discountValue !== undefined) data.discountValue = body.discountValue;
    if (body.minOrderValue !== undefined) data.minOrderValue = body.minOrderValue;
    if (body.maxUses !== undefined) data.maxUses = body.maxUses;
    if (body.usesCount !== undefined) data.usesCount = body.usesCount;
    if (body.validFrom !== undefined) data.validFrom = body.validFrom != null ? new Date(body.validFrom) : null;
    if (body.validUntil !== undefined) data.validUntil = body.validUntil != null ? new Date(body.validUntil) : null;
    if (body.isActive !== undefined) data.isActive = body.isActive;
    try {
    validate(data);
      const existing = await this.prisma.coupon.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.coupon.update({ where: { id: Number(id) }, data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.code !== undefined) data.code = body.code;
    if (body.discountType !== undefined) data.discountType = body.discountType;
    if (body.discountValue !== undefined) data.discountValue = body.discountValue;
    if (body.minOrderValue !== undefined) data.minOrderValue = body.minOrderValue;
    if (body.maxUses !== undefined) data.maxUses = body.maxUses;
    if (body.usesCount !== undefined) data.usesCount = body.usesCount;
    if (body.validFrom !== undefined) data.validFrom = body.validFrom != null ? new Date(body.validFrom) : null;
    if (body.validUntil !== undefined) data.validUntil = body.validUntil != null ? new Date(body.validUntil) : null;
    if (body.isActive !== undefined) data.isActive = body.isActive;
    try {
    validate(data);
      const existing = await this.prisma.coupon.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.coupon.update({ where: { id: Number(id) }, data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Get('/:id/valid')
  async is_valid(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.couponService.is_valid(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Get('/:id/applicable')
  async is_applicable_to_order(@Param('id') id: string, @Query('orderTotal') orderTotal: any) {
    let result: any;
    try {
      result = await this.couponService.is_applicable_to_order(Number(id), orderTotal);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/redeem')
  @HttpCode(204)
  async redeem(@Param('id') id: string) {
    try {
      await this.couponService.redeem(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/deactivate')
  @HttpCode(204)
  async deactivate(@Param('id') id: string) {
    try {
      await this.couponService.deactivate(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
