import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { DraftParticipantService } from '../../services/Content/draft_participant_service.js';

const router = Router();
const service = new DraftParticipantService();


router.get('/', async (_req, res) => {
  const items = await prisma.draftParticipant.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.seatNumber !== undefined) data.seatNumber = body.seatNumber;
    if (body.joinedAt !== undefined) data.joinedAt = body.joinedAt != null ? new Date(body.joinedAt) : null;
    if (body.sessionId !== undefined) data.sessionId = body.sessionId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
    const entity = await prisma.draftParticipant.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.draftParticipant.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.seatNumber !== undefined) data.seatNumber = body.seatNumber;
    if (body.joinedAt !== undefined) data.joinedAt = body.joinedAt != null ? new Date(body.joinedAt) : null;
    if (body.sessionId !== undefined) data.sessionId = body.sessionId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
    const entity = await prisma.draftParticipant.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.seatNumber !== undefined) data.seatNumber = body.seatNumber;
    if (body.joinedAt !== undefined) data.joinedAt = body.joinedAt != null ? new Date(body.joinedAt) : null;
    if (body.sessionId !== undefined) data.sessionId = body.sessionId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
    const entity = await prisma.draftParticipant.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.draftParticipant.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/pick', async (req, res) => {
  const id = Number((req.params as any).id);
  const cardId = req.body.cardId;
  const packNumber = req.body.packNumber;
  try {
    await service.pick_card(id, cardId, packNumber);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
