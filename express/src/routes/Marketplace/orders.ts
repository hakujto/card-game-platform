import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.order.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.total !== undefined) data.total = body.total;
    if (body.discountApplied !== undefined) data.discountApplied = body.discountApplied;
    if (body.currency !== undefined) data.currency = body.currency;
    if (body.paymentMethod !== undefined) data.paymentMethod = body.paymentMethod;
    if (body.paymentReference !== undefined) data.paymentReference = body.paymentReference;
    if (body.shippingAddress !== undefined) data.shippingAddress = body.shippingAddress;
    if (body.trackingNumber !== undefined) data.trackingNumber = body.trackingNumber;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.paidAt !== undefined) data.paidAt = new Date(body.paidAt);
    if (body.shippedAt !== undefined) data.shippedAt = new Date(body.shippedAt);
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.itemsId !== undefined) data.itemsId = body.itemsId;
    if (body.couponId !== undefined) data.couponId = body.couponId;
  try {
    const entity = await prisma.order.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.order.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.total !== undefined) data.total = body.total;
    if (body.discountApplied !== undefined) data.discountApplied = body.discountApplied;
    if (body.currency !== undefined) data.currency = body.currency;
    if (body.paymentMethod !== undefined) data.paymentMethod = body.paymentMethod;
    if (body.paymentReference !== undefined) data.paymentReference = body.paymentReference;
    if (body.shippingAddress !== undefined) data.shippingAddress = body.shippingAddress;
    if (body.trackingNumber !== undefined) data.trackingNumber = body.trackingNumber;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.paidAt !== undefined) data.paidAt = new Date(body.paidAt);
    if (body.shippedAt !== undefined) data.shippedAt = new Date(body.shippedAt);
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.itemsId !== undefined) data.itemsId = body.itemsId;
    if (body.couponId !== undefined) data.couponId = body.couponId;
  try {
    const entity = await prisma.order.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.total !== undefined) data.total = body.total;
    if (body.discountApplied !== undefined) data.discountApplied = body.discountApplied;
    if (body.currency !== undefined) data.currency = body.currency;
    if (body.paymentMethod !== undefined) data.paymentMethod = body.paymentMethod;
    if (body.paymentReference !== undefined) data.paymentReference = body.paymentReference;
    if (body.shippingAddress !== undefined) data.shippingAddress = body.shippingAddress;
    if (body.trackingNumber !== undefined) data.trackingNumber = body.trackingNumber;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.paidAt !== undefined) data.paidAt = new Date(body.paidAt);
    if (body.shippedAt !== undefined) data.shippedAt = new Date(body.shippedAt);
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.itemsId !== undefined) data.itemsId = body.itemsId;
    if (body.couponId !== undefined) data.couponId = body.couponId;
  try {
    const entity = await prisma.order.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.order.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
