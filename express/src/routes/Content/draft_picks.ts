import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { DraftPickService } from '../../services/Content/draft_pick_service.js';

const router = Router();
const service = new DraftPickService();

function validate(data: any): void {
  if (!((data.pickNumber == null || data.pickNumber > 0))) throw new Error(`Pick number must be greater than zero`);
  if (!((data.packNumber == null || (data.packNumber >= 1 && data.packNumber <= 3)))) throw new Error(`Pack number must be between 1 and 3`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.draftPick.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.pickNumber !== undefined) data.pickNumber = body.pickNumber;
    if (body.packNumber !== undefined) data.packNumber = body.packNumber;
    if (body.pickedAt !== undefined) data.pickedAt = body.pickedAt != null ? new Date(body.pickedAt) : null;
    if (body.participantId !== undefined) data.participantId = body.participantId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.draftPick.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.draftPick.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.pickNumber !== undefined) data.pickNumber = body.pickNumber;
    if (body.packNumber !== undefined) data.packNumber = body.packNumber;
    if (body.pickedAt !== undefined) data.pickedAt = body.pickedAt != null ? new Date(body.pickedAt) : null;
    if (body.participantId !== undefined) data.participantId = body.participantId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.draftPick.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.pickNumber !== undefined) data.pickNumber = body.pickNumber;
    if (body.packNumber !== undefined) data.packNumber = body.packNumber;
    if (body.pickedAt !== undefined) data.pickedAt = body.pickedAt != null ? new Date(body.pickedAt) : null;
    if (body.participantId !== undefined) data.participantId = body.participantId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.draftPick.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.draftPick.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.get('/:id/first-pick', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.is_first_pick(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
