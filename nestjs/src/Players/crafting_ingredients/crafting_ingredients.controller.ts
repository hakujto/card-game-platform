import { BadRequestException, Body, Controller, Delete, ForbiddenException, Get, HttpCode, NotFoundException, Param, Post, Query } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';


@Controller('crafting_ingredients')
export class CraftingIngredientController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.craftingIngredient.findMany();
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.recipeId !== undefined) data.recipeId = body.recipeId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    try {
      const entity = await this.prisma.craftingIngredient.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.craftingIngredient.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Delete(':id')
  @HttpCode(204)
  async remove(@Param('id') id: string) {
    try {
      await this.prisma.craftingIngredient.delete({ where: { id: Number(id) } });
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      throw new NotFoundException('Not found');
    }
  }
}
