import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

function validate(data: any): void {
  if (!((data.finalPlacement == null || data.finalPlacement > 0))) throw new Error(`Final placement must be greater than zero`);
  if ((data.claimed === true) && !((data.claimedAt === undefined || data.claimedAt != null))) throw new Error(`Claimed prize must have a claimed_at timestamp`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.awardedPrize.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.finalPlacement !== undefined) data.finalPlacement = body.finalPlacement;
    if (body.awardedAt !== undefined) data.awardedAt = body.awardedAt != null ? new Date(body.awardedAt) : null;
    if (body.claimed !== undefined) data.claimed = body.claimed;
    if (body.claimedAt !== undefined) data.claimedAt = body.claimedAt != null ? new Date(body.claimedAt) : null;
    if (body.prizeId !== undefined) data.prizeId = body.prizeId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
  validate(data);
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
    if (body.awardedAt !== undefined) data.awardedAt = body.awardedAt != null ? new Date(body.awardedAt) : null;
    if (body.claimed !== undefined) data.claimed = body.claimed;
    if (body.claimedAt !== undefined) data.claimedAt = body.claimedAt != null ? new Date(body.claimedAt) : null;
    if (body.prizeId !== undefined) data.prizeId = body.prizeId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
  validate(data);
    const entity = await prisma.awardedPrize.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.finalPlacement !== undefined) data.finalPlacement = body.finalPlacement;
    if (body.awardedAt !== undefined) data.awardedAt = body.awardedAt != null ? new Date(body.awardedAt) : null;
    if (body.claimed !== undefined) data.claimed = body.claimed;
    if (body.claimedAt !== undefined) data.claimedAt = body.claimedAt != null ? new Date(body.claimedAt) : null;
    if (body.prizeId !== undefined) data.prizeId = body.prizeId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
  validate(data);
    const entity = await prisma.awardedPrize.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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
