import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.draftSession.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.draftType !== undefined) data.draftType = body.draftType;
    if (body.seats !== undefined) data.seats = body.seats;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.completedAt !== undefined) data.completedAt = new Date(body.completedAt);
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
    if (body.participantsId !== undefined) data.participantsId = body.participantsId;
  try {
    const entity = await prisma.draftSession.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.draftSession.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.draftType !== undefined) data.draftType = body.draftType;
    if (body.seats !== undefined) data.seats = body.seats;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.completedAt !== undefined) data.completedAt = new Date(body.completedAt);
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
    if (body.participantsId !== undefined) data.participantsId = body.participantsId;
  try {
    const entity = await prisma.draftSession.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.draftType !== undefined) data.draftType = body.draftType;
    if (body.seats !== undefined) data.seats = body.seats;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.completedAt !== undefined) data.completedAt = new Date(body.completedAt);
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
    if (body.participantsId !== undefined) data.participantsId = body.participantsId;
  try {
    const entity = await prisma.draftSession.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.draftSession.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
