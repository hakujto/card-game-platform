import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();


router.get('/', async (req, res) => {
  const items = await prisma.deckTagAssignment.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.deckId !== undefined) data.deckId = body.deckId;
    if (body.tagId !== undefined) data.tagId = body.tagId;
  try {
    const entity = await prisma.deckTagAssignment.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.deckTagAssignment.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.deckTagAssignment.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
