import { prisma } from '../../lib/prisma.js';

export class CraftingIngredientService {
  async findAll() {
    return prisma.craftingIngredient.findMany();
  }

  async findOne(id: number) {
    return prisma.craftingIngredient.findUnique({ where: { id } });
  }

  async create(data: any) {
    return prisma.craftingIngredient.create({ data });
  }

  async update(id: number, data: any) {
    return prisma.craftingIngredient.update({ where: { id }, data });
  }

  async remove(id: number) {
    return prisma.craftingIngredient.delete({ where: { id } });
  }

}
