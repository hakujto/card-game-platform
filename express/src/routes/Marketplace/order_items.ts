import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

function validate(data: any): void {
  if (!((data.quantity == null || data.quantity > 0))) throw new Error(`Order item quantity must be greater than zero`);
  if (!((data.priceAtPurchase == null || Number(data.priceAtPurchase) >= 0))) throw new Error(`Price at purchase must not be negative`);
}

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
  validate(data);
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
  validate(data);
    const entity = await prisma.orderItem.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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
  validate(data);
    const entity = await prisma.orderItem.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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
