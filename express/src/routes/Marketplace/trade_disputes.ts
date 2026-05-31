import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TradeDisputeService } from '../../services/Marketplace/trade_dispute_service.js';

const router = Router();
const service = new TradeDisputeService();

function validate(data: any): void {
  if ((data.resolvedAt != null) && !(data.status === 'RESOLVED')) throw new Error(`resolved_at_requires_terminal_status`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('openedAt' in r) { r.openedAt = r.openedAt; delete r.openedAt; }
  if ('resolvedAt' in r) { r.resolvedAt = r.resolvedAt; delete r.resolvedAt; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Open': ['UnderReview'],
  'UnderReview': ['Resolved', 'Escalated'],
  'Escalated': ['Resolved']
};

function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

class TradeDisputeLifecycleService {

  async transitionOpenToUnderReview(id: number): Promise<any> {
    const entity = await prisma.tradeDispute.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeDispute not found: ' + id);
    assertTransition((entity as any).status, 'UnderReview');
    const updated = await prisma.tradeDispute.update({ where: { id }, data: { status: 'UNDERREVIEW' as any } });
    // TODO: entity.review(); // @after
    return updated;
  }

  async transitionUnderReviewToResolved(id: number): Promise<any> {
    const entity = await prisma.tradeDispute.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeDispute not found: ' + id);
    assertTransition((entity as any).status, 'Resolved');
    if ((entity as any).resolution == null) throw new Error('resolution is required for UnderReview -> Resolved');
    const updated = await prisma.tradeDispute.update({ where: { id }, data: { status: 'RESOLVED' as any } });
    // TODO: entity.closeResolved(); // @after
    return updated;
  }

  async transitionUnderReviewToEscalated(id: number): Promise<any> {
    const entity = await prisma.tradeDispute.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeDispute not found: ' + id);
    assertTransition((entity as any).status, 'Escalated');
    const updated = await prisma.tradeDispute.update({ where: { id }, data: { status: 'ESCALATED' as any } });
    // TODO: entity.escalate(); // @after
    return updated;
  }

  async transitionEscalatedToResolved(id: number): Promise<any> {
    const entity = await prisma.tradeDispute.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeDispute not found: ' + id);
    assertTransition((entity as any).status, 'Resolved');
    if ((entity as any).resolution == null) throw new Error('resolution is required for Escalated -> Resolved');
    const updated = await prisma.tradeDispute.update({ where: { id }, data: { status: 'RESOLVED' as any } });
    // TODO: entity.closeResolved(); // @after
    return updated;
  }

  async transitionResolvedToOpen(id: number): Promise<any> {
    const entity = await prisma.tradeDispute.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeDispute not found: ' + id);
    throw new Error('Transition Resolved -> Open is not allowed');
  }
}
const lifecycleService = new TradeDisputeLifecycleService();


router.get('/', async (req, res) => {
  const items = await prisma.tradeDispute.findMany();
  res.json(items.map(applyProjection));
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.reason !== undefined) data.reason = body.reason;
    if (body.description !== undefined) data.description = body.description;
    if (body.resolution !== undefined) data.resolution = body.resolution;
    if (body.openedAt !== undefined) data.openedAt = body.openedAt != null ? new Date(body.openedAt) : null;
    if (body.resolvedAt !== undefined) data.resolvedAt = body.resolvedAt != null ? new Date(body.resolvedAt) : null;
    if (body.transactionId !== undefined) data.transactionId = body.transactionId;
    if (body.openedById !== undefined) data.openedById = body.openedById;
    if (body.resolvedById !== undefined) data.resolvedById = body.resolvedById;
  try {
  validate(data);
    const entity = await prisma.tradeDispute.create({ data });
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tradeDispute.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
});

router.post('/:id/escalate', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.escalate(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/resolve', async (req, res) => {
  const id = Number((req.params as any).id);
  const resolutionText = req.body.resolutionText;
  try {
    await service.resolve(id, resolutionText);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/close', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.close_resolved(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/review', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.review(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/transitions/open-to-underreview', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionOpenToUnderReview(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/underreview-to-resolved', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionUnderReviewToResolved(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/underreview-to-escalated', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionUnderReviewToEscalated(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/escalated-to-resolved', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionEscalatedToResolved(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/resolved-to-open', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionResolvedToOpen(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});
export default router;
