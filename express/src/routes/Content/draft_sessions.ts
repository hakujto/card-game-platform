import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { DraftSessionService } from '../../services/Content/draft_session_service.js';

const router = Router();
const service = new DraftSessionService();

function validate(data: any): void {
  if (!((data.seats == null || (data.seats >= 2 && data.seats <= 16)))) throw new Error(`Draft session must have between 2 and 16 seats`);
  if ((data.completedAt != null) && !(data.status === 'COMPLETED')) throw new Error(`completed_at can only be set when draft status is Completed`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.draftSession.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.draftType !== undefined) data.draftType = body.draftType;
    if (body.seats !== undefined) data.seats = body.seats;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.completedAt !== undefined) data.completedAt = body.completedAt != null ? new Date(body.completedAt) : null;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
  try {
  validate(data);
    const entity = await prisma.draftSession.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.draftSession.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.draftType !== undefined) data.draftType = body.draftType;
    if (body.seats !== undefined) data.seats = body.seats;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.completedAt !== undefined) data.completedAt = body.completedAt != null ? new Date(body.completedAt) : null;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
  try {
  validate(data);
    const entity = await prisma.draftSession.update({ where: { id: Number(req.params.id) }, data });
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
    if (body.draftType !== undefined) data.draftType = body.draftType;
    if (body.seats !== undefined) data.seats = body.seats;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.completedAt !== undefined) data.completedAt = body.completedAt != null ? new Date(body.completedAt) : null;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
  try {
  validate(data);
    const entity = await prisma.draftSession.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.draftSession.delete({ where: { id: Number(req.params.id) } });
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

router.post('/:id/abandon', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.abandon(id);
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
