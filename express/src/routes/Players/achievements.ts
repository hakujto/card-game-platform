import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();


router.get('/', async (_req, res) => {
  const items = await prisma.achievement.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.iconUrl !== undefined) data.iconUrl = body.iconUrl;
    if (body.points !== undefined) data.points = body.points;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
  try {
    const entity = await prisma.achievement.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.achievement.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.iconUrl !== undefined) data.iconUrl = body.iconUrl;
    if (body.points !== undefined) data.points = body.points;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
  try {
    const entity = await prisma.achievement.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.iconUrl !== undefined) data.iconUrl = body.iconUrl;
    if (body.points !== undefined) data.points = body.points;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
  try {
    const entity = await prisma.achievement.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.achievement.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
