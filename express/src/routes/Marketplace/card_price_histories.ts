import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.cardPriceHistory.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.priceDate !== undefined) data.priceDate = new Date(body.priceDate);
    if (body.avgPrice !== undefined) data.avgPrice = body.avgPrice;
    if (body.minPrice !== undefined) data.minPrice = body.minPrice;
    if (body.maxPrice !== undefined) data.maxPrice = body.maxPrice;
    if (body.volume !== undefined) data.volume = body.volume;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.cardPriceHistory.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.cardPriceHistory.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.priceDate !== undefined) data.priceDate = new Date(body.priceDate);
    if (body.avgPrice !== undefined) data.avgPrice = body.avgPrice;
    if (body.minPrice !== undefined) data.minPrice = body.minPrice;
    if (body.maxPrice !== undefined) data.maxPrice = body.maxPrice;
    if (body.volume !== undefined) data.volume = body.volume;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.cardPriceHistory.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.priceDate !== undefined) data.priceDate = new Date(body.priceDate);
    if (body.avgPrice !== undefined) data.avgPrice = body.avgPrice;
    if (body.minPrice !== undefined) data.minPrice = body.minPrice;
    if (body.maxPrice !== undefined) data.maxPrice = body.maxPrice;
    if (body.volume !== undefined) data.volume = body.volume;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.cardPriceHistory.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.cardPriceHistory.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
