import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { PlayerCollectionService } from '../../services/Players/player_collection_service.js';

const router = Router();
const service = new PlayerCollectionService();

function validate(data: any): void {
  if (!((data.quantity == null || data.quantity > 0))) throw new Error(`Collection quantity must be greater than zero`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.playerCollection.findMany();
  res.json(items);
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
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.playerCollection.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
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
    const entity = await prisma.playerCollection.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
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
    const entity = await prisma.playerCollection.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
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
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/value', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.estimated_value(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
