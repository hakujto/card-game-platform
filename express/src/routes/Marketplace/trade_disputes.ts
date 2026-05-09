import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.tradeDispute.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.reason !== undefined) data.reason = body.reason;
    if (body.description !== undefined) data.description = body.description;
    if (body.status !== undefined) data.status = body.status;
    if (body.resolution !== undefined) data.resolution = body.resolution;
    if (body.openedAt !== undefined) data.openedAt = new Date(body.openedAt);
    if (body.resolvedAt !== undefined) data.resolvedAt = new Date(body.resolvedAt);
    if (body.transactionId !== undefined) data.transactionId = body.transactionId;
    if (body.openedById !== undefined) data.openedById = body.openedById;
    if (body.resolvedById !== undefined) data.resolvedById = body.resolvedById;
  try {
    const entity = await prisma.tradeDispute.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tradeDispute.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.reason !== undefined) data.reason = body.reason;
    if (body.description !== undefined) data.description = body.description;
    if (body.status !== undefined) data.status = body.status;
    if (body.resolution !== undefined) data.resolution = body.resolution;
    if (body.openedAt !== undefined) data.openedAt = new Date(body.openedAt);
    if (body.resolvedAt !== undefined) data.resolvedAt = new Date(body.resolvedAt);
    if (body.transactionId !== undefined) data.transactionId = body.transactionId;
    if (body.openedById !== undefined) data.openedById = body.openedById;
    if (body.resolvedById !== undefined) data.resolvedById = body.resolvedById;
  try {
    const entity = await prisma.tradeDispute.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.reason !== undefined) data.reason = body.reason;
    if (body.description !== undefined) data.description = body.description;
    if (body.status !== undefined) data.status = body.status;
    if (body.resolution !== undefined) data.resolution = body.resolution;
    if (body.openedAt !== undefined) data.openedAt = new Date(body.openedAt);
    if (body.resolvedAt !== undefined) data.resolvedAt = new Date(body.resolvedAt);
    if (body.transactionId !== undefined) data.transactionId = body.transactionId;
    if (body.openedById !== undefined) data.openedById = body.openedById;
    if (body.resolvedById !== undefined) data.resolvedById = body.resolvedById;
  try {
    const entity = await prisma.tradeDispute.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.tradeDispute.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
