import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.orderItem.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.priceAtPurchase !== undefined) data.priceAtPurchase = body.priceAtPurchase;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.orderId !== undefined) data.orderId = body.orderId;
    if (body.productId !== undefined) data.productId = body.productId;
  try {
    const entity = await prisma.orderItem.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.orderItem.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.priceAtPurchase !== undefined) data.priceAtPurchase = body.priceAtPurchase;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.orderId !== undefined) data.orderId = body.orderId;
    if (body.productId !== undefined) data.productId = body.productId;
  try {
    const entity = await prisma.orderItem.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.priceAtPurchase !== undefined) data.priceAtPurchase = body.priceAtPurchase;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.orderId !== undefined) data.orderId = body.orderId;
    if (body.productId !== undefined) data.productId = body.productId;
  try {
    const entity = await prisma.orderItem.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.orderItem.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
