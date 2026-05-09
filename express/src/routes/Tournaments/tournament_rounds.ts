import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.tournamentRound.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.roundNumber !== undefined) data.roundNumber = body.roundNumber;
    if (body.status !== undefined) data.status = body.status;
    if (body.startedAt !== undefined) data.startedAt = new Date(body.startedAt);
    if (body.endedAt !== undefined) data.endedAt = new Date(body.endedAt);
    if (body.timeLimitMinutes !== undefined) data.timeLimitMinutes = body.timeLimitMinutes;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.matchesId !== undefined) data.matchesId = body.matchesId;
  try {
    const entity = await prisma.tournamentRound.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tournamentRound.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.roundNumber !== undefined) data.roundNumber = body.roundNumber;
    if (body.status !== undefined) data.status = body.status;
    if (body.startedAt !== undefined) data.startedAt = new Date(body.startedAt);
    if (body.endedAt !== undefined) data.endedAt = new Date(body.endedAt);
    if (body.timeLimitMinutes !== undefined) data.timeLimitMinutes = body.timeLimitMinutes;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.matchesId !== undefined) data.matchesId = body.matchesId;
  try {
    const entity = await prisma.tournamentRound.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.roundNumber !== undefined) data.roundNumber = body.roundNumber;
    if (body.status !== undefined) data.status = body.status;
    if (body.startedAt !== undefined) data.startedAt = new Date(body.startedAt);
    if (body.endedAt !== undefined) data.endedAt = new Date(body.endedAt);
    if (body.timeLimitMinutes !== undefined) data.timeLimitMinutes = body.timeLimitMinutes;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.matchesId !== undefined) data.matchesId = body.matchesId;
  try {
    const entity = await prisma.tournamentRound.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.tournamentRound.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
