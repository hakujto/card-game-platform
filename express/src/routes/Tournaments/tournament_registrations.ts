import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TournamentRegistrationService } from '../../services/Tournaments/tournament_registration_service.js';

const router = Router();
const service = new TournamentRegistrationService();

function validate(data: any): void {
  if (!((data.pointsEarned == null || data.pointsEarned >= 0))) throw new Error(`Points earned must not be negative`);
  if ((data.finalStanding != null) && !((data.finalStanding == null || data.finalStanding > 0))) throw new Error(`Final standing must be greater than zero`);
  if ((data.seed != null) && !((data.seed == null || data.seed > 0))) throw new Error(`Seed must be greater than zero`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('registeredAt' in r) { r.registeredAt = r.registeredAt; delete r.registeredAt; }
  return r;
}


router.get('/', async (req, res) => {
  const items = await prisma.tournamentRegistration.findMany();
  res.json(items.map(applyProjection));
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
  validate(data);
    const entity = await prisma.tournamentRegistration.create({ data });
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tournamentRegistration.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  if (entity.playerId !== (req as any).userId) return res.status(403).json({ error: 'You do not own this resource.' });
  res.json(applyProjection(entity));
});

router.post('/:id/withdraw', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.withdraw(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/disqualify', async (req, res) => {
  const id = Number((req.params as any).id);
  const reason = req.body.reason;
  try {
    await service.disqualify(id, reason);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/promote', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.promote_from_waitlist(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
