import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { OrderItemService } from './order_item.service';


function validate(data: any): void {
  if (!((data.quantity == null || data.quantity > 0))) throw new Error(`Order item quantity must be greater than zero`);
  if (!((data.priceAtPurchase == null || Number(data.priceAtPurchase) >= 0))) throw new Error(`Price at purchase must not be negative`);
}

@Controller('order_items')
export class OrderItemController {
  constructor(private readonly prisma: PrismaService, private readonly orderItemService: OrderItemService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.orderItem.findMany();
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.priceAtPurchase !== undefined) data.priceAtPurchase = body.priceAtPurchase;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.orderId !== undefined) data.orderId = body.orderId;
    if (body.productId !== undefined) data.productId = body.productId;
    try {
    validate(data);
      const entity = await this.prisma.orderItem.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.orderItem.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Delete(':id')
  @HttpCode(204)
  async remove(@Param('id') id: string) {
    try {
      await this.prisma.orderItem.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }

  @Get('/:id/total')
  async line_total(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.orderItemService.line_total(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
