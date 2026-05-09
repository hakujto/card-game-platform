import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.playerSeasonStats.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.wins !== undefined) data.wins = body.wins;
    if (body.losses !== undefined) data.losses = body.losses;
    if (body.draws !== undefined) data.draws = body.draws;
    if (body.tournamentWins !== undefined) data.tournamentWins = body.tournamentWins;
    if (body.highestRank !== undefined) data.highestRank = body.highestRank;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
  try {
    const entity = await prisma.playerSeasonStats.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.playerSeasonStats.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.wins !== undefined) data.wins = body.wins;
    if (body.losses !== undefined) data.losses = body.losses;
    if (body.draws !== undefined) data.draws = body.draws;
    if (body.tournamentWins !== undefined) data.tournamentWins = body.tournamentWins;
    if (body.highestRank !== undefined) data.highestRank = body.highestRank;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
  try {
    const entity = await prisma.playerSeasonStats.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.wins !== undefined) data.wins = body.wins;
    if (body.losses !== undefined) data.losses = body.losses;
    if (body.draws !== undefined) data.draws = body.draws;
    if (body.tournamentWins !== undefined) data.tournamentWins = body.tournamentWins;
    if (body.highestRank !== undefined) data.highestRank = body.highestRank;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
  try {
    const entity = await prisma.playerSeasonStats.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.playerSeasonStats.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
