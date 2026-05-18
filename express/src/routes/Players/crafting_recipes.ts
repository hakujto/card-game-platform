import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { CraftingRecipeService } from '../../services/Players/crafting_recipe_service.js';

const router = Router();
const service = new CraftingRecipeService();

function validate(data: any): void {
  if (!((data.dustCost == null || data.dustCost > 0))) throw new Error(`Crafting recipe must have a dust cost greater than zero`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.craftingRecipe.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.dustCost !== undefined) data.dustCost = body.dustCost;
    if (body.isAvailable !== undefined) data.isAvailable = body.isAvailable;
    if (body.resultCardId !== undefined) data.resultCardId = body.resultCardId;
  try {
  validate(data);
    const entity = await prisma.craftingRecipe.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.craftingRecipe.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.dustCost !== undefined) data.dustCost = body.dustCost;
    if (body.isAvailable !== undefined) data.isAvailable = body.isAvailable;
    if (body.resultCardId !== undefined) data.resultCardId = body.resultCardId;
  try {
  validate(data);
    const entity = await prisma.craftingRecipe.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.dustCost !== undefined) data.dustCost = body.dustCost;
    if (body.isAvailable !== undefined) data.isAvailable = body.isAvailable;
    if (body.resultCardId !== undefined) data.resultCardId = body.resultCardId;
  try {
  validate(data);
    const entity = await prisma.craftingRecipe.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.craftingRecipe.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.get('/:id/can-craft', async (req, res) => {
  const id = Number((req.params as any).id);
  const playerId = (req.query as any).playerId;
  try {
    const result = await service.can_craft(id, playerId);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/craft', async (req, res) => {
  const id = Number((req.params as any).id);
  const playerId = req.body.playerId;
  try {
    await service.execute_craft(id, playerId);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/disable', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.disable(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/enable', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.enable(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
