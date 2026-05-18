import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();


router.get('/', async (_req, res) => {
  const items = await prisma.articleTagAssignment.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.articleId !== undefined) data.articleId = body.articleId;
    if (body.tagId !== undefined) data.tagId = body.tagId;
  try {
    const entity = await prisma.articleTagAssignment.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.articleTagAssignment.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.articleId !== undefined) data.articleId = body.articleId;
    if (body.tagId !== undefined) data.tagId = body.tagId;
  try {
    const entity = await prisma.articleTagAssignment.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.articleId !== undefined) data.articleId = body.articleId;
    if (body.tagId !== undefined) data.tagId = body.tagId;
  try {
    const entity = await prisma.articleTagAssignment.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.articleTagAssignment.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
