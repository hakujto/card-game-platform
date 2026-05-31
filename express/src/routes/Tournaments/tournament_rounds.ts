import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TournamentRoundService } from '../../services/Tournaments/tournament_round_service.js';

const router = Router();
const service = new TournamentRoundService();

function validate(data: any): void {
  if (!((data.roundNumber == null || data.roundNumber > 0))) throw new Error(`Round number must be greater than zero`);
  if (!((data.timeLimitMinutes == null || data.timeLimitMinutes > 0))) throw new Error(`Round time limit must be greater than zero`);
  if ((data.endedAt != null) && !((data.endedAt == null || (data.startedAt != null && data.endedAt > data.startedAt)))) throw new Error(`Round end time must be after start time`);
  if ((data.status === 'COMPLETED') && !((data.startedAt === undefined || data.startedAt != null))) throw new Error(`Completed round must have a start time`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('startedAt' in r) { r.startedAt = r.startedAt; delete r.startedAt; }
  if ('endedAt' in r) { r.endedAt = r.endedAt; delete r.endedAt; }
  return r;
}


router.get('/', async (req, res) => {
  const items = await prisma.tournamentRound.findMany();
  res.json(items.map(applyProjection));
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
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tournamentRound.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
});

router.post('/:id/start', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.start(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/complete', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.complete(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/pairings', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.generate_pairings(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/time-expired', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.is_time_expired(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
