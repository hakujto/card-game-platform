import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { DraftParticipantService } from '../../services/Content/draft_participant_service.js';

const router = Router();
const service = new DraftParticipantService();

function validate(data: any): void {
  if (!((data.seatNumber == null || data.seatNumber > 0))) throw new Error(`Seat number must be greater than zero`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('joinedAt' in r) { r.joinedAt = r.joinedAt; delete r.joinedAt; }
  return r;
}


router.get('/', async (req, res) => {
  const items = await prisma.draftParticipant.findMany();
  res.json(items.map(applyProjection));
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.seatNumber !== undefined) data.seatNumber = body.seatNumber;
    if (body.joinedAt !== undefined) data.joinedAt = body.joinedAt != null ? new Date(body.joinedAt) : null;
    if (body.sessionId !== undefined) data.sessionId = body.sessionId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
  validate(data);
    const entity = await prisma.draftParticipant.create({ data });
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.draftParticipant.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
});

router.post('/:id/pick', async (req, res) => {
  const id = Number((req.params as any).id);
  const cardId = req.body.cardId;
  const packNumber = req.body.packNumber;
  try {
    await service.pick_card(id, cardId, packNumber);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/card-count', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.drafted_card_count(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
