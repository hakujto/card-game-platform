import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.playerCollection.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.acquiredAt !== undefined) data.acquiredAt = new Date(body.acquiredAt);
    if (body.acquiredVia !== undefined) data.acquiredVia = body.acquiredVia;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.playerCollection.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.playerCollection.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.acquiredAt !== undefined) data.acquiredAt = new Date(body.acquiredAt);
    if (body.acquiredVia !== undefined) data.acquiredVia = body.acquiredVia;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.playerCollection.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.acquiredAt !== undefined) data.acquiredAt = new Date(body.acquiredAt);
    if (body.acquiredVia !== undefined) data.acquiredVia = body.acquiredVia;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.playerCollection.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.playerCollection.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
