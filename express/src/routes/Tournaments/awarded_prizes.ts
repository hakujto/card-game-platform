import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.awardedPrize.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.finalPlacement !== undefined) data.finalPlacement = body.finalPlacement;
    if (body.awardedAt !== undefined) data.awardedAt = new Date(body.awardedAt);
    if (body.claimed !== undefined) data.claimed = body.claimed;
    if (body.claimedAt !== undefined) data.claimedAt = new Date(body.claimedAt);
    if (body.prizeId !== undefined) data.prizeId = body.prizeId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
    const entity = await prisma.awardedPrize.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.awardedPrize.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.finalPlacement !== undefined) data.finalPlacement = body.finalPlacement;
    if (body.awardedAt !== undefined) data.awardedAt = new Date(body.awardedAt);
    if (body.claimed !== undefined) data.claimed = body.claimed;
    if (body.claimedAt !== undefined) data.claimedAt = new Date(body.claimedAt);
    if (body.prizeId !== undefined) data.prizeId = body.prizeId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
    const entity = await prisma.awardedPrize.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.finalPlacement !== undefined) data.finalPlacement = body.finalPlacement;
    if (body.awardedAt !== undefined) data.awardedAt = new Date(body.awardedAt);
    if (body.claimed !== undefined) data.claimed = body.claimed;
    if (body.claimedAt !== undefined) data.claimedAt = new Date(body.claimedAt);
    if (body.prizeId !== undefined) data.prizeId = body.prizeId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
    const entity = await prisma.awardedPrize.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.awardedPrize.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
