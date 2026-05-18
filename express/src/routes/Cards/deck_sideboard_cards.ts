import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();


router.get('/', async (_req, res) => {
  const items = await prisma.deckSideboardCard.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.deckId !== undefined) data.deckId = body.deckId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.deckSideboardCard.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.deckSideboardCard.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.deckId !== undefined) data.deckId = body.deckId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.deckSideboardCard.update({ where: { id: Number(req.params.id) }, data });
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
    if (body.deckId !== undefined) data.deckId = body.deckId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.deckSideboardCard.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.deckSideboardCard.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
