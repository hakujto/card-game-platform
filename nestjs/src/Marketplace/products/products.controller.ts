import { BadRequestException, Body, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { ProductService } from './product.service';


function validate(data: any): void {
  if (data.discountPercent != null && Number(data.discountPercent) < 0) throw new Error('discount_percent: must be >= 0');
  if (data.discountPercent != null && Number(data.discountPercent) > 100) throw new Error('discount_percent: must be <= 100');
  if (!((data.price == null || Number(data.price) > 0))) throw new Error(`Product price must be greater than zero`);
  if (!((data.stock == null || data.stock >= 0))) throw new Error(`Product stock must not be negative`);
  if (!((data.discountPercent == null || (data.discountPercent >= 0 && data.discountPercent <= 100)))) throw new Error(`Product discount percent must be between 0 and 100`);
}

@Controller('products')
export class ProductController {
  constructor(private readonly prisma: PrismaService, private readonly productService: ProductService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ name: { contains: q } }, { description: { contains: q } }] } : undefined;
    const items = await this.prisma.product.findMany(where ? { where } : undefined);
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.productType !== undefined) data.productType = body.productType;
    if (body.price !== undefined) data.price = body.price;
    if (body.stock !== undefined) data.stock = body.stock;
    if (body.active !== undefined) data.active = body.active;
    if (body.discountPercent !== undefined) data.discountPercent = body.discountPercent;
    if (body.description !== undefined) data.description = body.description;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.featured !== undefined) data.featured = body.featured;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
    try {
    validate(data);
      const entity = await this.prisma.product.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.product.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.productType !== undefined) data.productType = body.productType;
    if (body.price !== undefined) data.price = body.price;
    if (body.stock !== undefined) data.stock = body.stock;
    if (body.active !== undefined) data.active = body.active;
    if (body.discountPercent !== undefined) data.discountPercent = body.discountPercent;
    if (body.description !== undefined) data.description = body.description;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.featured !== undefined) data.featured = body.featured;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
    try {
    validate(data);
      const existing = await this.prisma.product.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.product.update({ where: { id: Number(id) }, data });
      return entity;
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.productType !== undefined) data.productType = body.productType;
    if (body.price !== undefined) data.price = body.price;
    if (body.stock !== undefined) data.stock = body.stock;
    if (body.active !== undefined) data.active = body.active;
    if (body.discountPercent !== undefined) data.discountPercent = body.discountPercent;
    if (body.description !== undefined) data.description = body.description;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.featured !== undefined) data.featured = body.featured;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
    try {
    validate(data);
      const existing = await this.prisma.product.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.product.update({ where: { id: Number(id) }, data });
      return entity;
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Post('/:id/activate')
  @HttpCode(204)
  async activate(@Param('id') id: string) {
    try {
      await this.productService.activate(Number(id));
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
      await this.productService.deactivate(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch('/:id/discount')
  async apply_discount(@Param('id') id: string, @Body() body: any) {
    let result: any;
    try {
      result = await this.productService.apply_discount(Number(id), body.percent);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/restock')
  @HttpCode(204)
  async restock(@Param('id') id: string, @Body() body: any) {
    try {
      await this.productService.restock(Number(id), body.quantity);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/effective-price')
  async effective_price(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.productService.effective_price(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Get('/:id/in-stock')
  async is_in_stock(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.productService.is_in_stock(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
