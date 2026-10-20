import { BadRequestException, Body, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CraftingRecipeService } from './crafting_recipe.service';


function validate(data: any): void {
  if (!((data.dustCost == null || data.dustCost > 0))) throw new Error(`Crafting recipe must have a dust cost greater than zero`);
}

@Controller('crafting_recipes')
export class CraftingRecipeController {
  constructor(private readonly prisma: PrismaService, private readonly craftingRecipeService: CraftingRecipeService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.craftingRecipe.findMany();
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.dustCost !== undefined) data.dustCost = body.dustCost;
    if (body.isAvailable !== undefined) data.isAvailable = body.isAvailable;
    if (body.resultCardId !== undefined) data.resultCardId = body.resultCardId;
    try {
    validate(data);
      const entity = await this.prisma.craftingRecipe.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.craftingRecipe.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.dustCost !== undefined) data.dustCost = body.dustCost;
    if (body.isAvailable !== undefined) data.isAvailable = body.isAvailable;
    if (body.resultCardId !== undefined) data.resultCardId = body.resultCardId;
    try {
    validate(data);
      const existing = await this.prisma.craftingRecipe.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.craftingRecipe.update({ where: { id: Number(id) }, data });
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
    if (body.dustCost !== undefined) data.dustCost = body.dustCost;
    if (body.isAvailable !== undefined) data.isAvailable = body.isAvailable;
    if (body.resultCardId !== undefined) data.resultCardId = body.resultCardId;
    try {
    validate(data);
      const existing = await this.prisma.craftingRecipe.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.craftingRecipe.update({ where: { id: Number(id) }, data });
      return entity;
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Get('/:id/can-craft')
  async can_craft(@Param('id') id: string, @Query('playerId') playerId: any) {
    let result: any;
    try {
      result = await this.craftingRecipeService.can_craft(Number(id), playerId);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/craft')
  @HttpCode(204)
  async execute_craft(@Param('id') id: string, @Body() body: any) {
    try {
      await this.craftingRecipeService.execute_craft(Number(id), body.playerId);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/disable')
  @HttpCode(204)
  async disable(@Param('id') id: string) {
    try {
      await this.craftingRecipeService.disable(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/enable')
  @HttpCode(204)
  async enable(@Param('id') id: string) {
    try {
      await this.craftingRecipeService.enable(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
