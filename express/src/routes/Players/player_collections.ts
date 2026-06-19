import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { PlayerCollectionService } from '../../services/Players/player_collection_service.js';

const router = Router();
const service = new PlayerCollectionService();

function validate(data: any): void {
  if (!((data.quantity == null || data.quantity > 0))) throw new Error(`Collection quantity must be greater than zero`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('acquiredAt' in r) { r.acquiredAt = r.acquiredAt; delete r.acquiredAt; }
  return r;
}


router.get('/', async (req, res) => {
  const items = await prisma.playerCollection.findMany();
  res.json(items.map(applyProjection));
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.acquiredAt !== undefined) data.acquiredAt = body.acquiredAt != null ? new Date(body.acquiredAt) : null;
    if (body.acquiredVia !== undefined) data.acquiredVia = body.acquiredVia;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.playerCollection.create({ data });
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.playerCollection.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  if (entity.playerId !== (req as any).userId) return res.status(403).json({ error: 'You do not own this resource.' });
  res.json(applyProjection(entity));
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.acquiredAt !== undefined) data.acquiredAt = body.acquiredAt != null ? new Date(body.acquiredAt) : null;
    if (body.acquiredVia !== undefined) data.acquiredVia = body.acquiredVia;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const existing = await prisma.playerCollection.findUnique({ where: { id: Number(req.params.id) } });
    if (!existing) return res.status(404).json({ error: 'Not found' });
  if (existing.playerId !== (req as any).userId) return res.status(403).json({ error: 'You do not own this resource.' });
    const entity = await prisma.playerCollection.update({ where: { id: Number(req.params.id) }, data });
    res.json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const existing = await prisma.playerCollection.findUnique({ where: { id: Number(req.params.id) } });
    if (!existing) return res.status(404).json({ error: 'Not found' });
  if (existing.playerId !== (req as any).userId) return res.status(403).json({ error: 'You do not own this resource.' });
    await prisma.playerCollection.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/add', async (req, res) => {
  const id = Number((req.params as any).id);
  const quantity = req.body.quantity;
  try {
    await service.add(id, quantity);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/value', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.estimated_value(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
