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
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('startTime' in r) { r.startTime = r.startTime; delete r.startTime; }
  if ('endTime' in r) { r.endTime = r.endTime; delete r.endTime; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Draft': ['Registration'],
  'Registration': ['Ongoing', 'Cancelled'],
  'Ongoing': ['Completed', 'Cancelled']
};

function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

class TournamentLifecycleService {

  async transitionDraftToRegistration(id: number): Promise<any> {
    const entity = await prisma.tournament.findUnique({ where: { id } });
    if (!entity) throw new Error('Tournament not found: ' + id);
    assertTransition((entity as any).status, 'Registration');
    if ((entity as any).name == null) throw new Error('name is required for Draft -> Registration');
    if ((entity as any).startTime == null) throw new Error('start_time is required for Draft -> Registration');
    const updated = await prisma.tournament.update({ where: { id }, data: { status: 'REGISTRATION' as any } });
    return updated;
  }

  async transitionRegistrationToOngoing(id: number): Promise<any> {
    const entity = await prisma.tournament.findUnique({ where: { id } });
    if (!entity) throw new Error('Tournament not found: ' + id);
    assertTransition((entity as any).status, 'Ongoing');
    const updated = await prisma.tournament.update({ where: { id }, data: { status: 'ONGOING' as any } });
    // TODO: entity.start(); // @after
    return updated;
  }

  async transitionRegistrationToCancelled(id: number): Promise<any> {
    const entity = await prisma.tournament.findUnique({ where: { id } });
    if (!entity) throw new Error('Tournament not found: ' + id);
    assertTransition((entity as any).status, 'Cancelled');
    const updated = await prisma.tournament.update({ where: { id }, data: { status: 'CANCELLED' as any } });
    // TODO: entity.cancel(); // @after
    return updated;
  }

  async transitionOngoingToCompleted(id: number): Promise<any> {
    const entity = await prisma.tournament.findUnique({ where: { id } });
    if (!entity) throw new Error('Tournament not found: ' + id);
    assertTransition((entity as any).status, 'Completed');
    const updated = await prisma.tournament.update({ where: { id }, data: { status: 'COMPLETED' as any } });
    // TODO: entity.complete(); // @after
    // TODO: entity.calculatePrizeDistribution(); // @after
    return updated;
  }

  async transitionOngoingToCancelled(id: number): Promise<any> {
    const entity = await prisma.tournament.findUnique({ where: { id } });
    if (!entity) throw new Error('Tournament not found: ' + id);
    assertTransition((entity as any).status, 'Cancelled');
    const updated = await prisma.tournament.update({ where: { id }, data: { status: 'CANCELLED' as any } });
    // TODO: entity.cancel(); // @after
    return updated;
  }

  async transitionCompletedToDraft(id: number): Promise<any> {
    const entity = await prisma.tournament.findUnique({ where: { id } });
    if (!entity) throw new Error('Tournament not found: ' + id);
    throw new Error('Transition Completed -> Draft is not allowed');
  }

  async transitionCancelledToDraft(id: number): Promise<any> {
    const entity = await prisma.tournament.findUnique({ where: { id } });
    if (!entity) throw new Error('Tournament not found: ' + id);
    throw new Error('Transition Cancelled -> Draft is not allowed');
  }
}
const lifecycleService = new TournamentLifecycleService();


router.get('/', async (req, res) => {
  const q = req.query.q as string | undefined;
  const where = q ? { OR: [{ name: { contains: q } }, { description: { contains: q } }] } : undefined;
  const items = await prisma.tournament.findMany(where ? { where } : undefined);
  res.json(items.map(applyProjection));
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.status !== undefined) data.status = body.status;
    if (body.format !== undefined) data.format = body.format;
    if (body.tournamentType !== undefined) data.tournamentType = body.tournamentType;
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
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tournament.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.status !== undefined) data.status = body.status;
    if (body.format !== undefined) data.format = body.format;
    if (body.tournamentType !== undefined) data.tournamentType = body.tournamentType;
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
    res.json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.status !== undefined) data.status = body.status;
    if (body.format !== undefined) data.format = body.format;
    if (body.tournamentType !== undefined) data.tournamentType = body.tournamentType;
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
    res.json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
  }
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

router.post('/:id/cancel', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.cancel(id);
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

router.post('/:id/rounds', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.generate_round(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/prizes', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.calculate_prize_distribution(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
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
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/full', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.is_full(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/transitions/draft-to-registration', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionDraftToRegistration(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/registration-to-ongoing', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionRegistrationToOngoing(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/registration-to-cancelled', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionRegistrationToCancelled(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/ongoing-to-completed', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionOngoingToCompleted(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/ongoing-to-cancelled', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionOngoingToCancelled(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/completed-to-draft', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionCompletedToDraft(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/cancelled-to-draft', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionCancelledToDraft(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});
export default router;
