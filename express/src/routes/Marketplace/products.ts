import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.product.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.productType !== undefined) data.productType = body.productType;
    if (body.price !== undefined) data.price = body.price;
    if (body.stock !== undefined) data.stock = body.stock;
    if (body.active !== undefined) data.active = body.active;
    if (body.discountPercent !== undefined) data.discountPercent = body.discountPercent;
    if (body.description !== undefined) data.description = body.description;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.featured !== undefined) data.featured = body.featured;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
  try {
    const entity = await prisma.product.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.product.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.productType !== undefined) data.productType = body.productType;
    if (body.price !== undefined) data.price = body.price;
    if (body.stock !== undefined) data.stock = body.stock;
    if (body.active !== undefined) data.active = body.active;
    if (body.discountPercent !== undefined) data.discountPercent = body.discountPercent;
    if (body.description !== undefined) data.description = body.description;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.featured !== undefined) data.featured = body.featured;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
  try {
    const entity = await prisma.product.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.productType !== undefined) data.productType = body.productType;
    if (body.price !== undefined) data.price = body.price;
    if (body.stock !== undefined) data.stock = body.stock;
    if (body.active !== undefined) data.active = body.active;
    if (body.discountPercent !== undefined) data.discountPercent = body.discountPercent;
    if (body.description !== undefined) data.description = body.description;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.featured !== undefined) data.featured = body.featured;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
  try {
    const entity = await prisma.product.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.product.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
