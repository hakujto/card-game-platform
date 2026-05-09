import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.game.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.gameNumber !== undefined) data.gameNumber = body.gameNumber;
    if (body.winnerSide !== undefined) data.winnerSide = body.winnerSide;
    if (body.turnsPlayed !== undefined) data.turnsPlayed = body.turnsPlayed;
    if (body.durationSeconds !== undefined) data.durationSeconds = body.durationSeconds;
    if (body.endedBy !== undefined) data.endedBy = body.endedBy;
    if (body.replayUrl !== undefined) data.replayUrl = body.replayUrl;
    if (body.matchId !== undefined) data.matchId = body.matchId;
    if (body.winnerId !== undefined) data.winnerId = body.winnerId;
  try {
    const entity = await prisma.game.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.game.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.gameNumber !== undefined) data.gameNumber = body.gameNumber;
    if (body.winnerSide !== undefined) data.winnerSide = body.winnerSide;
    if (body.turnsPlayed !== undefined) data.turnsPlayed = body.turnsPlayed;
    if (body.durationSeconds !== undefined) data.durationSeconds = body.durationSeconds;
    if (body.endedBy !== undefined) data.endedBy = body.endedBy;
    if (body.replayUrl !== undefined) data.replayUrl = body.replayUrl;
    if (body.matchId !== undefined) data.matchId = body.matchId;
    if (body.winnerId !== undefined) data.winnerId = body.winnerId;
  try {
    const entity = await prisma.game.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.gameNumber !== undefined) data.gameNumber = body.gameNumber;
    if (body.winnerSide !== undefined) data.winnerSide = body.winnerSide;
    if (body.turnsPlayed !== undefined) data.turnsPlayed = body.turnsPlayed;
    if (body.durationSeconds !== undefined) data.durationSeconds = body.durationSeconds;
    if (body.endedBy !== undefined) data.endedBy = body.endedBy;
    if (body.replayUrl !== undefined) data.replayUrl = body.replayUrl;
    if (body.matchId !== undefined) data.matchId = body.matchId;
    if (body.winnerId !== undefined) data.winnerId = body.winnerId;
  try {
    const entity = await prisma.game.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.game.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
