import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

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
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.updatedAt !== undefined) data.updatedAt = new Date(body.updatedAt);
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
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.updatedAt !== undefined) data.updatedAt = new Date(body.updatedAt);
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
    const entity = await prisma.deck.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
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
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.updatedAt !== undefined) data.updatedAt = new Date(body.updatedAt);
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
    const entity = await prisma.deck.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
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

export default router;
