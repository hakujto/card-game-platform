import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { ArticleCommentService } from '../../services/Content/article_comment_service.js';

const router = Router();
const service = new ArticleCommentService();


router.get('/', async (_req, res) => {
  const items = await prisma.articleComment.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.body !== undefined) data.body = body.body;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
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
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.articleId !== undefined) data.articleId = body.articleId;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.parentCommentId !== undefined) data.parentCommentId = body.parentCommentId;
  try {
    const entity = await prisma.articleComment.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.body !== undefined) data.body = body.body;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.articleId !== undefined) data.articleId = body.articleId;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.parentCommentId !== undefined) data.parentCommentId = body.parentCommentId;
  try {
    const entity = await prisma.articleComment.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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

router.post('/:id/hide', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.hide(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/unhide', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.unhide(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
