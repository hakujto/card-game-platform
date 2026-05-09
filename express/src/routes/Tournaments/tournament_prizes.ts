import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.tournamentPrize.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.placementFrom !== undefined) data.placementFrom = body.placementFrom;
    if (body.placementTo !== undefined) data.placementTo = body.placementTo;
    if (body.prizeType !== undefined) data.prizeType = body.prizeType;
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.description !== undefined) data.description = body.description;
    if (body.packsCount !== undefined) data.packsCount = body.packsCount;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
  try {
    const entity = await prisma.tournamentPrize.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tournamentPrize.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.placementFrom !== undefined) data.placementFrom = body.placementFrom;
    if (body.placementTo !== undefined) data.placementTo = body.placementTo;
    if (body.prizeType !== undefined) data.prizeType = body.prizeType;
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.description !== undefined) data.description = body.description;
    if (body.packsCount !== undefined) data.packsCount = body.packsCount;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
  try {
    const entity = await prisma.tournamentPrize.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.placementFrom !== undefined) data.placementFrom = body.placementFrom;
    if (body.placementTo !== undefined) data.placementTo = body.placementTo;
    if (body.prizeType !== undefined) data.prizeType = body.prizeType;
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.description !== undefined) data.description = body.description;
    if (body.packsCount !== undefined) data.packsCount = body.packsCount;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
  try {
    const entity = await prisma.tournamentPrize.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.tournamentPrize.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
