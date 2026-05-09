import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.coupon.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.code !== undefined) data.code = body.code;
    if (body.discountType !== undefined) data.discountType = body.discountType;
    if (body.discountValue !== undefined) data.discountValue = body.discountValue;
    if (body.minOrderValue !== undefined) data.minOrderValue = body.minOrderValue;
    if (body.maxUses !== undefined) data.maxUses = body.maxUses;
    if (body.usesCount !== undefined) data.usesCount = body.usesCount;
    if (body.validFrom !== undefined) data.validFrom = new Date(body.validFrom);
    if (body.validUntil !== undefined) data.validUntil = new Date(body.validUntil);
    if (body.isActive !== undefined) data.isActive = body.isActive;
  try {
    const entity = await prisma.coupon.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.coupon.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.code !== undefined) data.code = body.code;
    if (body.discountType !== undefined) data.discountType = body.discountType;
    if (body.discountValue !== undefined) data.discountValue = body.discountValue;
    if (body.minOrderValue !== undefined) data.minOrderValue = body.minOrderValue;
    if (body.maxUses !== undefined) data.maxUses = body.maxUses;
    if (body.usesCount !== undefined) data.usesCount = body.usesCount;
    if (body.validFrom !== undefined) data.validFrom = new Date(body.validFrom);
    if (body.validUntil !== undefined) data.validUntil = new Date(body.validUntil);
    if (body.isActive !== undefined) data.isActive = body.isActive;
  try {
    const entity = await prisma.coupon.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.code !== undefined) data.code = body.code;
    if (body.discountType !== undefined) data.discountType = body.discountType;
    if (body.discountValue !== undefined) data.discountValue = body.discountValue;
    if (body.minOrderValue !== undefined) data.minOrderValue = body.minOrderValue;
    if (body.maxUses !== undefined) data.maxUses = body.maxUses;
    if (body.usesCount !== undefined) data.usesCount = body.usesCount;
    if (body.validFrom !== undefined) data.validFrom = new Date(body.validFrom);
    if (body.validUntil !== undefined) data.validUntil = new Date(body.validUntil);
    if (body.isActive !== undefined) data.isActive = body.isActive;
  try {
    const entity = await prisma.coupon.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.coupon.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
