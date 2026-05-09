import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.article.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.slug !== undefined) data.slug = body.slug;
    if (body.body !== undefined) data.body = body.body;
    if (body.excerpt !== undefined) data.excerpt = body.excerpt;
    if (body.coverImageUrl !== undefined) data.coverImageUrl = body.coverImageUrl;
    if (body.status !== undefined) data.status = body.status;
    if (body.articleType !== undefined) data.articleType = body.articleType;
    if (body.viewCount !== undefined) data.viewCount = body.viewCount;
    if (body.publishedAt !== undefined) data.publishedAt = new Date(body.publishedAt);
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.updatedAt !== undefined) data.updatedAt = new Date(body.updatedAt);
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
    if (body.commentsId !== undefined) data.commentsId = body.commentsId;
  try {
    const entity = await prisma.article.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.article.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.slug !== undefined) data.slug = body.slug;
    if (body.body !== undefined) data.body = body.body;
    if (body.excerpt !== undefined) data.excerpt = body.excerpt;
    if (body.coverImageUrl !== undefined) data.coverImageUrl = body.coverImageUrl;
    if (body.status !== undefined) data.status = body.status;
    if (body.articleType !== undefined) data.articleType = body.articleType;
    if (body.viewCount !== undefined) data.viewCount = body.viewCount;
    if (body.publishedAt !== undefined) data.publishedAt = new Date(body.publishedAt);
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.updatedAt !== undefined) data.updatedAt = new Date(body.updatedAt);
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
    if (body.commentsId !== undefined) data.commentsId = body.commentsId;
  try {
    const entity = await prisma.article.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.slug !== undefined) data.slug = body.slug;
    if (body.body !== undefined) data.body = body.body;
    if (body.excerpt !== undefined) data.excerpt = body.excerpt;
    if (body.coverImageUrl !== undefined) data.coverImageUrl = body.coverImageUrl;
    if (body.status !== undefined) data.status = body.status;
    if (body.articleType !== undefined) data.articleType = body.articleType;
    if (body.viewCount !== undefined) data.viewCount = body.viewCount;
    if (body.publishedAt !== undefined) data.publishedAt = new Date(body.publishedAt);
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.updatedAt !== undefined) data.updatedAt = new Date(body.updatedAt);
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
    if (body.commentsId !== undefined) data.commentsId = body.commentsId;
  try {
    const entity = await prisma.article.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.article.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
