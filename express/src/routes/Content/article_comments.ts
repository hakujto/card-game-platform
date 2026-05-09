import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.articleComment.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.body !== undefined) data.body = body.body;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.articleId !== undefined) data.articleId = body.articleId;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.parentCommentId !== undefined) data.parentCommentId = body.parentCommentId;
  try {
    const entity = await prisma.articleComment.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.articleComment.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.body !== undefined) data.body = body.body;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.articleId !== undefined) data.articleId = body.articleId;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.parentCommentId !== undefined) data.parentCommentId = body.parentCommentId;
  try {
    const entity = await prisma.articleComment.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.body !== undefined) data.body = body.body;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.articleId !== undefined) data.articleId = body.articleId;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.parentCommentId !== undefined) data.parentCommentId = body.parentCommentId;
  try {
    const entity = await prisma.articleComment.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.articleComment.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
