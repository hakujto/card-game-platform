import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.draftPick.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.pickNumber !== undefined) data.pickNumber = body.pickNumber;
    if (body.packNumber !== undefined) data.packNumber = body.packNumber;
    if (body.pickedAt !== undefined) data.pickedAt = new Date(body.pickedAt);
    if (body.participantId !== undefined) data.participantId = body.participantId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.draftPick.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.draftPick.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.pickNumber !== undefined) data.pickNumber = body.pickNumber;
    if (body.packNumber !== undefined) data.packNumber = body.packNumber;
    if (body.pickedAt !== undefined) data.pickedAt = new Date(body.pickedAt);
    if (body.participantId !== undefined) data.participantId = body.participantId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.draftPick.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.pickNumber !== undefined) data.pickNumber = body.pickNumber;
    if (body.packNumber !== undefined) data.packNumber = body.packNumber;
    if (body.pickedAt !== undefined) data.pickedAt = new Date(body.pickedAt);
    if (body.participantId !== undefined) data.participantId = body.participantId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.draftPick.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.draftPick.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
