import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { ArticleService } from '../../services/Content/article_service.js';

const router = Router();
const service = new ArticleService();

function validate(data: any): void {
  if ((data.status === 'PUBLISHED') && !((data.publishedAt === undefined || data.publishedAt != null))) throw new Error(`Published article must have a published_at timestamp`);
}

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
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
  try {
  validate(data);
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
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
  try {
  validate(data);
    const entity = await prisma.article.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
  try {
  validate(data);
    const entity = await prisma.article.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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

router.post('/:id/publish', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.publish(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/archive', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.archive(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/view', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.increment_view(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
