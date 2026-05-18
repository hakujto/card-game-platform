import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

function validate(data: any): void {
  if (!((data.placementTo == null || (data.placementFrom != null && data.placementTo >= data.placementFrom)))) throw new Error(`placement_to must be greater than or equal to placement_from`);
  if (!((data.placementFrom == null || data.placementFrom > 0))) throw new Error(`placement_from must be greater than zero`);
  if (!((data.amount == null || Number(data.amount) >= 0))) throw new Error(`Prize amount must not be negative`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.tournamentPrize.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.placementFrom !== undefined) data.placementFrom = body.placementFrom;
    if (body.placementTo !== undefined) data.placementTo = body.placementTo;
    if (body.prizeType !== undefined) data.prizeType = body.prizeType;
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.description !== undefined) data.description = body.description;
    if (body.packsCount !== undefined) data.packsCount = body.packsCount;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
  try {
  validate(data);
    const entity = await prisma.tournamentPrize.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tournamentPrize.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.placementFrom !== undefined) data.placementFrom = body.placementFrom;
    if (body.placementTo !== undefined) data.placementTo = body.placementTo;
    if (body.prizeType !== undefined) data.prizeType = body.prizeType;
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.description !== undefined) data.description = body.description;
    if (body.packsCount !== undefined) data.packsCount = body.packsCount;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
  try {
  validate(data);
    const entity = await prisma.tournamentPrize.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.placementFrom !== undefined) data.placementFrom = body.placementFrom;
    if (body.placementTo !== undefined) data.placementTo = body.placementTo;
    if (body.prizeType !== undefined) data.prizeType = body.prizeType;
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.description !== undefined) data.description = body.description;
    if (body.packsCount !== undefined) data.packsCount = body.packsCount;
    if (body.seasonPoints !== undefined) data.seasonPoints = body.seasonPoints;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
  try {
  validate(data);
    const entity = await prisma.tournamentPrize.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.tournamentPrize.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
