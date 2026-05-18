import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TournamentRegistrationService } from '../../services/Tournaments/tournament_registration_service.js';

const router = Router();
const service = new TournamentRegistrationService();


router.get('/', async (_req, res) => {
  const items = await prisma.tournamentRegistration.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.seed !== undefined) data.seed = body.seed;
    if (body.finalStanding !== undefined) data.finalStanding = body.finalStanding;
    if (body.pointsEarned !== undefined) data.pointsEarned = body.pointsEarned;
    if (body.registeredAt !== undefined) data.registeredAt = body.registeredAt != null ? new Date(body.registeredAt) : null;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.deckId !== undefined) data.deckId = body.deckId;
  try {
    const entity = await prisma.tournamentRegistration.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tournamentRegistration.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.seed !== undefined) data.seed = body.seed;
    if (body.finalStanding !== undefined) data.finalStanding = body.finalStanding;
    if (body.pointsEarned !== undefined) data.pointsEarned = body.pointsEarned;
    if (body.registeredAt !== undefined) data.registeredAt = body.registeredAt != null ? new Date(body.registeredAt) : null;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.deckId !== undefined) data.deckId = body.deckId;
  try {
    const entity = await prisma.tournamentRegistration.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.seed !== undefined) data.seed = body.seed;
    if (body.finalStanding !== undefined) data.finalStanding = body.finalStanding;
    if (body.pointsEarned !== undefined) data.pointsEarned = body.pointsEarned;
    if (body.registeredAt !== undefined) data.registeredAt = body.registeredAt != null ? new Date(body.registeredAt) : null;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.deckId !== undefined) data.deckId = body.deckId;
  try {
    const entity = await prisma.tournamentRegistration.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.tournamentRegistration.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/withdraw', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.withdraw(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/disqualify', async (req, res) => {
  const id = Number((req.params as any).id);
  const reason = req.body.reason;
  try {
    await service.disqualify(id, reason);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/promote', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.promote_from_waitlist(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
