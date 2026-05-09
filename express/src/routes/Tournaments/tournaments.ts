import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.tournament.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.tournamentType !== undefined) data.tournamentType = body.tournamentType;
    if (body.status !== undefined) data.status = body.status;
    if (body.maxPlayers !== undefined) data.maxPlayers = body.maxPlayers;
    if (body.entryFee !== undefined) data.entryFee = body.entryFee;
    if (body.prizePool !== undefined) data.prizePool = body.prizePool;
    if (body.startTime !== undefined) data.startTime = new Date(body.startTime);
    if (body.endTime !== undefined) data.endTime = new Date(body.endTime);
    if (body.isOnline !== undefined) data.isOnline = body.isOnline;
    if (body.location !== undefined) data.location = body.location;
    if (body.rulesText !== undefined) data.rulesText = body.rulesText;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
    if (body.organizerId !== undefined) data.organizerId = body.organizerId;
    if (body.registrationsId !== undefined) data.registrationsId = body.registrationsId;
    if (body.roundsId !== undefined) data.roundsId = body.roundsId;
    if (body.prizesId !== undefined) data.prizesId = body.prizesId;
  try {
    const entity = await prisma.tournament.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tournament.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.tournamentType !== undefined) data.tournamentType = body.tournamentType;
    if (body.status !== undefined) data.status = body.status;
    if (body.maxPlayers !== undefined) data.maxPlayers = body.maxPlayers;
    if (body.entryFee !== undefined) data.entryFee = body.entryFee;
    if (body.prizePool !== undefined) data.prizePool = body.prizePool;
    if (body.startTime !== undefined) data.startTime = new Date(body.startTime);
    if (body.endTime !== undefined) data.endTime = new Date(body.endTime);
    if (body.isOnline !== undefined) data.isOnline = body.isOnline;
    if (body.location !== undefined) data.location = body.location;
    if (body.rulesText !== undefined) data.rulesText = body.rulesText;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
    if (body.organizerId !== undefined) data.organizerId = body.organizerId;
    if (body.registrationsId !== undefined) data.registrationsId = body.registrationsId;
    if (body.roundsId !== undefined) data.roundsId = body.roundsId;
    if (body.prizesId !== undefined) data.prizesId = body.prizesId;
  try {
    const entity = await prisma.tournament.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.tournamentType !== undefined) data.tournamentType = body.tournamentType;
    if (body.status !== undefined) data.status = body.status;
    if (body.maxPlayers !== undefined) data.maxPlayers = body.maxPlayers;
    if (body.entryFee !== undefined) data.entryFee = body.entryFee;
    if (body.prizePool !== undefined) data.prizePool = body.prizePool;
    if (body.startTime !== undefined) data.startTime = new Date(body.startTime);
    if (body.endTime !== undefined) data.endTime = new Date(body.endTime);
    if (body.isOnline !== undefined) data.isOnline = body.isOnline;
    if (body.location !== undefined) data.location = body.location;
    if (body.rulesText !== undefined) data.rulesText = body.rulesText;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
    if (body.organizerId !== undefined) data.organizerId = body.organizerId;
    if (body.registrationsId !== undefined) data.registrationsId = body.registrationsId;
    if (body.roundsId !== undefined) data.roundsId = body.roundsId;
    if (body.prizesId !== undefined) data.prizesId = body.prizesId;
  try {
    const entity = await prisma.tournament.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.tournament.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
