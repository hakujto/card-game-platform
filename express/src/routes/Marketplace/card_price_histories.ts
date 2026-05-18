import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

function validate(data: any): void {
  if (!(((data.minPrice == null || (data.avgPrice != null && Number(data.minPrice) <= Number(data.avgPrice))) && (data.avgPrice == null || (data.maxPrice != null && Number(data.avgPrice) <= Number(data.maxPrice)))))) throw new Error(`min_price <= avg_price <= max_price must hold`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.cardPriceHistory.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.priceDate !== undefined) data.priceDate = body.priceDate != null ? new Date(body.priceDate) : null;
    if (body.avgPrice !== undefined) data.avgPrice = body.avgPrice;
    if (body.minPrice !== undefined) data.minPrice = body.minPrice;
    if (body.maxPrice !== undefined) data.maxPrice = body.maxPrice;
    if (body.volume !== undefined) data.volume = body.volume;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
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
    if (body.priceDate !== undefined) data.priceDate = body.priceDate != null ? new Date(body.priceDate) : null;
    if (body.avgPrice !== undefined) data.avgPrice = body.avgPrice;
    if (body.minPrice !== undefined) data.minPrice = body.minPrice;
    if (body.maxPrice !== undefined) data.maxPrice = body.maxPrice;
    if (body.volume !== undefined) data.volume = body.volume;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.cardPriceHistory.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.priceDate !== undefined) data.priceDate = body.priceDate != null ? new Date(body.priceDate) : null;
    if (body.avgPrice !== undefined) data.avgPrice = body.avgPrice;
    if (body.minPrice !== undefined) data.minPrice = body.minPrice;
    if (body.maxPrice !== undefined) data.maxPrice = body.maxPrice;
    if (body.volume !== undefined) data.volume = body.volume;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.cardPriceHistory.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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
