import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { DraftSessionService } from '../../services/Content/draft_session_service.js';

const router = Router();
const service = new DraftSessionService();

function validate(data: any): void {
  if (!((data.seats == null || (data.seats >= 2 && data.seats <= 16)))) throw new Error(`Draft session must have between 2 and 16 seats`);
  if (!((data.timePerPickSeconds == null || data.timePerPickSeconds > 0))) throw new Error(`Time per pick must be greater than zero`);
  if ((data.completedAt != null) && !(data.status === 'COMPLETED')) throw new Error(`completed_at can only be set when draft status is Completed`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('completedAt' in r) { r.completedAt = r.completedAt; delete r.completedAt; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'WaitingForPlayers': ['Drafting', 'Abandoned'],
  'Drafting': ['Completed', 'Abandoned']
};

function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

class DraftSessionLifecycleService {

  async transitionWaitingForPlayersToDrafting(id: number): Promise<any> {
    const entity = await prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    assertTransition((entity as any).status, 'Drafting');
    const updated = await prisma.draftSession.update({ where: { id }, data: { status: 'DRAFTING' as any } });
    // TODO: entity.start(); // @after
    return updated;
  }

  async transitionDraftingToCompleted(id: number): Promise<any> {
    const entity = await prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    assertTransition((entity as any).status, 'Completed');
    const updated = await prisma.draftSession.update({ where: { id }, data: { status: 'COMPLETED' as any } });
    // TODO: entity.complete(); // @after
    return updated;
  }

  async transitionDraftingToAbandoned(id: number): Promise<any> {
    const entity = await prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    assertTransition((entity as any).status, 'Abandoned');
    const updated = await prisma.draftSession.update({ where: { id }, data: { status: 'ABANDONED' as any } });
    // TODO: entity.abandon(); // @after
    return updated;
  }

  async transitionWaitingForPlayersToAbandoned(id: number): Promise<any> {
    const entity = await prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    assertTransition((entity as any).status, 'Abandoned');
    const updated = await prisma.draftSession.update({ where: { id }, data: { status: 'ABANDONED' as any } });
    // TODO: entity.abandon(); // @after
    return updated;
  }

  async transitionCompletedToDrafting(id: number): Promise<any> {
    const entity = await prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    throw new Error('Transition Completed -> Drafting is not allowed');
  }

  async transitionAbandonedToDrafting(id: number): Promise<any> {
    const entity = await prisma.draftSession.findUnique({ where: { id } });
    if (!entity) throw new Error('DraftSession not found: ' + id);
    throw new Error('Transition Abandoned -> Drafting is not allowed');
  }
}
const lifecycleService = new DraftSessionLifecycleService();


router.get('/', async (req, res) => {
  const items = await prisma.draftSession.findMany();
  res.json(items.map(applyProjection));
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.draftType !== undefined) data.draftType = body.draftType;
    if (body.packContents !== undefined) data.packContents = body.packContents;
    if (body.seats !== undefined) data.seats = body.seats;
    if (body.timePerPickSeconds !== undefined) data.timePerPickSeconds = body.timePerPickSeconds;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.completedAt !== undefined) data.completedAt = body.completedAt != null ? new Date(body.completedAt) : null;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
  try {
  validate(data);
    const entity = await prisma.draftSession.create({ data });
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.draftSession.findUnique({ where: { id: Number(req.params.id) } });
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

router.post('/:id/abandon', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.abandon(id);
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

router.patch('/:id/transitions/waitingforplayers-to-drafting', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionWaitingForPlayersToDrafting(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/drafting-to-completed', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionDraftingToCompleted(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/drafting-to-abandoned', async (req, res) => {
  const id = Number(req.params.id);
  const userRole = (req as any).user?.role;
  if (!['Admin', 'Organizer'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for transition Drafting -> Abandoned' }); return; }
  try {
    const entity = await lifecycleService.transitionDraftingToAbandoned(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/waitingforplayers-to-abandoned', async (req, res) => {
  const id = Number(req.params.id);
  const userRole = (req as any).user?.role;
  if (!['Admin', 'Organizer'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for transition WaitingForPlayers -> Abandoned' }); return; }
  try {
    const entity = await lifecycleService.transitionWaitingForPlayersToAbandoned(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/completed-to-drafting', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionCompletedToDrafting(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/abandoned-to-drafting', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionAbandonedToDrafting(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});
export default router;
