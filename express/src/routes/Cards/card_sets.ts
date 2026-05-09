import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.cardSet.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.code !== undefined) data.code = body.code;
    if (body.releaseDate !== undefined) data.releaseDate = new Date(body.releaseDate);
    if (body.setType !== undefined) data.setType = body.setType;
    if (body.totalCards !== undefined) data.totalCards = body.totalCards;
    if (body.description !== undefined) data.description = body.description;
    if (body.logoUrl !== undefined) data.logoUrl = body.logoUrl;
  try {
    const entity = await prisma.cardSet.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.cardSet.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.code !== undefined) data.code = body.code;
    if (body.releaseDate !== undefined) data.releaseDate = new Date(body.releaseDate);
    if (body.setType !== undefined) data.setType = body.setType;
    if (body.totalCards !== undefined) data.totalCards = body.totalCards;
    if (body.description !== undefined) data.description = body.description;
    if (body.logoUrl !== undefined) data.logoUrl = body.logoUrl;
  try {
    const entity = await prisma.cardSet.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.code !== undefined) data.code = body.code;
    if (body.releaseDate !== undefined) data.releaseDate = new Date(body.releaseDate);
    if (body.setType !== undefined) data.setType = body.setType;
    if (body.totalCards !== undefined) data.totalCards = body.totalCards;
    if (body.description !== undefined) data.description = body.description;
    if (body.logoUrl !== undefined) data.logoUrl = body.logoUrl;
  try {
    const entity = await prisma.cardSet.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.cardSet.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
