import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TournamentRoundService } from '../../services/Tournaments/tournament_round_service.js';

const router = Router();
const service = new TournamentRoundService();

function validate(data: any): void {
  if ((data.endedAt != null) && !((data.endedAt == null || (data.startedAt != null && data.endedAt > data.startedAt)))) throw new Error(`Round end time must be after start time`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.tournamentRound.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.roundNumber !== undefined) data.roundNumber = body.roundNumber;
    if (body.status !== undefined) data.status = body.status;
    if (body.startedAt !== undefined) data.startedAt = body.startedAt != null ? new Date(body.startedAt) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.timeLimitMinutes !== undefined) data.timeLimitMinutes = body.timeLimitMinutes;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
  try {
  validate(data);
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
    if (body.startedAt !== undefined) data.startedAt = body.startedAt != null ? new Date(body.startedAt) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.timeLimitMinutes !== undefined) data.timeLimitMinutes = body.timeLimitMinutes;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
  try {
  validate(data);
    const entity = await prisma.tournamentRound.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.roundNumber !== undefined) data.roundNumber = body.roundNumber;
    if (body.status !== undefined) data.status = body.status;
    if (body.startedAt !== undefined) data.startedAt = body.startedAt != null ? new Date(body.startedAt) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.timeLimitMinutes !== undefined) data.timeLimitMinutes = body.timeLimitMinutes;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
  try {
  validate(data);
    const entity = await prisma.tournamentRound.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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

router.post('/:id/start', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.start(id);
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

router.post('/:id/pairings', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.generate_pairings(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
