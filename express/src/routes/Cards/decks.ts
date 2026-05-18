import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { DeckService } from '../../services/Cards/deck_service.js';

const router = Router();
const service = new DeckService();


router.get('/', async (_req, res) => {
  const items = await prisma.deck.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.isPublic !== undefined) data.isPublic = body.isPublic;
    if (body.isTournamentLegal !== undefined) data.isTournamentLegal = body.isTournamentLegal;
    if (body.archetype !== undefined) data.archetype = body.archetype;
    if (body.wins !== undefined) data.wins = body.wins;
    if (body.losses !== undefined) data.losses = body.losses;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
    const entity = await prisma.deck.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.deck.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.isPublic !== undefined) data.isPublic = body.isPublic;
    if (body.isTournamentLegal !== undefined) data.isTournamentLegal = body.isTournamentLegal;
    if (body.archetype !== undefined) data.archetype = body.archetype;
    if (body.wins !== undefined) data.wins = body.wins;
    if (body.losses !== undefined) data.losses = body.losses;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
    const entity = await prisma.deck.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.isPublic !== undefined) data.isPublic = body.isPublic;
    if (body.isTournamentLegal !== undefined) data.isTournamentLegal = body.isTournamentLegal;
    if (body.archetype !== undefined) data.archetype = body.archetype;
    if (body.wins !== undefined) data.wins = body.wins;
    if (body.losses !== undefined) data.losses = body.losses;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
    const entity = await prisma.deck.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.deck.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.get('/:id/validate', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.validate_size(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/clone', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.clone(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/publish', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.publish(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/unpublish', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.unpublish(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/certify', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.certify_tournament_legal(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
