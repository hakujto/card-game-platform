import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

function validate(data: any): void {
  if (!((data.amount == null || Number(data.amount) > 0))) throw new Error(`Bid amount must be greater than zero`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.tradeBid.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.placedAt !== undefined) data.placedAt = body.placedAt != null ? new Date(body.placedAt) : null;
    if (body.isWinning !== undefined) data.isWinning = body.isWinning;
    if (body.listingId !== undefined) data.listingId = body.listingId;
    if (body.bidderId !== undefined) data.bidderId = body.bidderId;
  try {
  validate(data);
    const entity = await prisma.tradeBid.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tradeBid.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.placedAt !== undefined) data.placedAt = body.placedAt != null ? new Date(body.placedAt) : null;
    if (body.isWinning !== undefined) data.isWinning = body.isWinning;
    if (body.listingId !== undefined) data.listingId = body.listingId;
    if (body.bidderId !== undefined) data.bidderId = body.bidderId;
  try {
  validate(data);
    const entity = await prisma.tradeBid.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.placedAt !== undefined) data.placedAt = body.placedAt != null ? new Date(body.placedAt) : null;
    if (body.isWinning !== undefined) data.isWinning = body.isWinning;
    if (body.listingId !== undefined) data.listingId = body.listingId;
    if (body.bidderId !== undefined) data.bidderId = body.bidderId;
  try {
  validate(data);
    const entity = await prisma.tradeBid.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.tradeBid.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
