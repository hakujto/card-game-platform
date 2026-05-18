import { prisma } from '../../lib/prisma.js';

export class CraftingRecipeService {
  async findAll() {
    return prisma.craftingRecipe.findMany();
  }

  async findOne(id: number) {
    return prisma.craftingRecipe.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.craftingRecipe.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.craftingRecipe.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.craftingRecipe.delete({ where: { id } });
  }

  async disable(): Promise<void> {
    throw new Error('disable not implemented');
  }

  async enable(): Promise<void> {
    throw new Error('enable not implemented');
  }
}
