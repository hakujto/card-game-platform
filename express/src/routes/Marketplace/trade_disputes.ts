import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TradeDisputeService } from '../../services/Marketplace/trade_dispute_service.js';

const router = Router();
const service = new TradeDisputeService();

function validate(data: any): void {
  if ((data.resolvedAt != null) && !(data.status === 'RESOLVED')) throw new Error(`resolved_at_requires_terminal_status`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.tradeDispute.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.reason !== undefined) data.reason = body.reason;
    if (body.description !== undefined) data.description = body.description;
    if (body.status !== undefined) data.status = body.status;
    if (body.resolution !== undefined) data.resolution = body.resolution;
    if (body.openedAt !== undefined) data.openedAt = body.openedAt != null ? new Date(body.openedAt) : null;
    if (body.resolvedAt !== undefined) data.resolvedAt = body.resolvedAt != null ? new Date(body.resolvedAt) : null;
    if (body.transactionId !== undefined) data.transactionId = body.transactionId;
    if (body.openedById !== undefined) data.openedById = body.openedById;
    if (body.resolvedById !== undefined) data.resolvedById = body.resolvedById;
  try {
  validate(data);
    const entity = await prisma.tradeDispute.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tradeDispute.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.reason !== undefined) data.reason = body.reason;
    if (body.description !== undefined) data.description = body.description;
    if (body.status !== undefined) data.status = body.status;
    if (body.resolution !== undefined) data.resolution = body.resolution;
    if (body.openedAt !== undefined) data.openedAt = body.openedAt != null ? new Date(body.openedAt) : null;
    if (body.resolvedAt !== undefined) data.resolvedAt = body.resolvedAt != null ? new Date(body.resolvedAt) : null;
    if (body.transactionId !== undefined) data.transactionId = body.transactionId;
    if (body.openedById !== undefined) data.openedById = body.openedById;
    if (body.resolvedById !== undefined) data.resolvedById = body.resolvedById;
  try {
  validate(data);
    const entity = await prisma.tradeDispute.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.reason !== undefined) data.reason = body.reason;
    if (body.description !== undefined) data.description = body.description;
    if (body.status !== undefined) data.status = body.status;
    if (body.resolution !== undefined) data.resolution = body.resolution;
    if (body.openedAt !== undefined) data.openedAt = body.openedAt != null ? new Date(body.openedAt) : null;
    if (body.resolvedAt !== undefined) data.resolvedAt = body.resolvedAt != null ? new Date(body.resolvedAt) : null;
    if (body.transactionId !== undefined) data.transactionId = body.transactionId;
    if (body.openedById !== undefined) data.openedById = body.openedById;
    if (body.resolvedById !== undefined) data.resolvedById = body.resolvedById;
  try {
  validate(data);
    const entity = await prisma.tradeDispute.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.tradeDispute.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/escalate', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.escalate(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/resolve', async (req, res) => {
  const id = Number((req.params as any).id);
  const resolutionText = req.body.resolutionText;
  try {
    await service.resolve(id, resolutionText);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/review', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.review(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
