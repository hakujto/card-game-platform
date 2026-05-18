import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TournamentService } from '../../services/Tournaments/tournament_service.js';

const router = Router();
const service = new TournamentService();

function validate(data: any): void {
  if (!((data.maxPlayers == null || (data.maxPlayers >= 2 && data.maxPlayers <= 512)))) throw new Error(`Tournament must allow between 2 and 512 players`);
  if (!((data.entryFee == null || Number(data.entryFee) >= 0))) throw new Error(`Entry fee must not be negative`);
  if (!((data.prizePool == null || Number(data.prizePool) >= 0))) throw new Error(`Prize pool must not be negative`);
  if ((data.endTime != null) && !((data.endTime == null || (data.startTime != null && data.endTime > data.startTime)))) throw new Error(`End time must be after start time`);
}

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
    if (body.startTime !== undefined) data.startTime = body.startTime != null ? new Date(body.startTime) : null;
    if (body.endTime !== undefined) data.endTime = body.endTime != null ? new Date(body.endTime) : null;
    if (body.isOnline !== undefined) data.isOnline = body.isOnline;
    if (body.location !== undefined) data.location = body.location;
    if (body.rulesText !== undefined) data.rulesText = body.rulesText;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
    if (body.organizerId !== undefined) data.organizerId = body.organizerId;
  try {
  validate(data);
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
    if (body.startTime !== undefined) data.startTime = body.startTime != null ? new Date(body.startTime) : null;
    if (body.endTime !== undefined) data.endTime = body.endTime != null ? new Date(body.endTime) : null;
    if (body.isOnline !== undefined) data.isOnline = body.isOnline;
    if (body.location !== undefined) data.location = body.location;
    if (body.rulesText !== undefined) data.rulesText = body.rulesText;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
    if (body.organizerId !== undefined) data.organizerId = body.organizerId;
  try {
  validate(data);
    const entity = await prisma.tournament.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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
    if (body.startTime !== undefined) data.startTime = body.startTime != null ? new Date(body.startTime) : null;
    if (body.endTime !== undefined) data.endTime = body.endTime != null ? new Date(body.endTime) : null;
    if (body.isOnline !== undefined) data.isOnline = body.isOnline;
    if (body.location !== undefined) data.location = body.location;
    if (body.rulesText !== undefined) data.rulesText = body.rulesText;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.seasonId !== undefined) data.seasonId = body.seasonId;
    if (body.organizerId !== undefined) data.organizerId = body.organizerId;
  try {
  validate(data);
    const entity = await prisma.tournament.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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

router.post('/:id/start', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.start(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/cancel', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.cancel(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/complete', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.complete(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/rounds', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.generate_round(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/prizes', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.calculate_prize_distribution(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/register', async (req, res) => {
  const id = Number((req.params as any).id);
  const playerId = req.body.playerId;
  const deckId = req.body.deckId;
  try {
    await service.register_player(id, playerId, deckId);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/full', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.is_full(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
