import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.tradeTransaction.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.finalPrice !== undefined) data.finalPrice = body.finalPrice;
    if (body.platformFee !== undefined) data.platformFee = body.platformFee;
    if (body.status !== undefined) data.status = body.status;
    if (body.completedAt !== undefined) data.completedAt = new Date(body.completedAt);
    if (body.listingId !== undefined) data.listingId = body.listingId;
    if (body.buyerId !== undefined) data.buyerId = body.buyerId;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
  try {
    const entity = await prisma.tradeTransaction.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tradeTransaction.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.finalPrice !== undefined) data.finalPrice = body.finalPrice;
    if (body.platformFee !== undefined) data.platformFee = body.platformFee;
    if (body.status !== undefined) data.status = body.status;
    if (body.completedAt !== undefined) data.completedAt = new Date(body.completedAt);
    if (body.listingId !== undefined) data.listingId = body.listingId;
    if (body.buyerId !== undefined) data.buyerId = body.buyerId;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
  try {
    const entity = await prisma.tradeTransaction.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.finalPrice !== undefined) data.finalPrice = body.finalPrice;
    if (body.platformFee !== undefined) data.platformFee = body.platformFee;
    if (body.status !== undefined) data.status = body.status;
    if (body.completedAt !== undefined) data.completedAt = new Date(body.completedAt);
    if (body.listingId !== undefined) data.listingId = body.listingId;
    if (body.buyerId !== undefined) data.buyerId = body.buyerId;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
  try {
    const entity = await prisma.tradeTransaction.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.tradeTransaction.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
