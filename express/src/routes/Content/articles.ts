import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { ArticleService } from '../../services/Content/article_service.js';

const router = Router();
const service = new ArticleService();

function validate(data: any): void {
  if (!((data.viewCount == null || data.viewCount >= 0))) throw new Error(`Article view count must not be negative`);
  if (!((data.likesCount == null || data.likesCount >= 0))) throw new Error(`Article likes count must not be negative`);
  if ((data.status === 'PUBLISHED') && !((data.publishedAt === undefined || data.publishedAt != null))) throw new Error(`Published article must have a published_at timestamp`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('updatedAt' in r) { r.updatedAt = r.updatedAt; delete r.updatedAt; }
  if ('publishedAt' in r) { r.publishedAt = r.publishedAt; delete r.publishedAt; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Draft': ['Published'],
  'Published': ['Archived'],
  'Archived': ['Draft']
};

function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

class ArticleLifecycleService {

  async transitionDraftToPublished(id: number): Promise<any> {
    const entity = await prisma.article.findUnique({ where: { id } });
    if (!entity) throw new Error('Article not found: ' + id);
    assertTransition((entity as any).status, 'Published');
    if ((entity as any).title == null) throw new Error('title is required for Draft -> Published');
    if ((entity as any).body == null) throw new Error('body is required for Draft -> Published');
    const updated = await prisma.article.update({ where: { id }, data: { status: 'PUBLISHED' as any } });
    // TODO: entity.publish(); // @after
    return updated;
  }

  async transitionPublishedToArchived(id: number): Promise<any> {
    const entity = await prisma.article.findUnique({ where: { id } });
    if (!entity) throw new Error('Article not found: ' + id);
    assertTransition((entity as any).status, 'Archived');
    const updated = await prisma.article.update({ where: { id }, data: { status: 'ARCHIVED' as any } });
    // TODO: entity.archive(); // @after
    return updated;
  }

  async transitionArchivedToDraft(id: number): Promise<any> {
    const entity = await prisma.article.findUnique({ where: { id } });
    if (!entity) throw new Error('Article not found: ' + id);
    assertTransition((entity as any).status, 'Draft');
    const updated = await prisma.article.update({ where: { id }, data: { status: 'DRAFT' as any } });
    return updated;
  }

  async transitionPublishedToDraft(id: number): Promise<any> {
    const entity = await prisma.article.findUnique({ where: { id } });
    if (!entity) throw new Error('Article not found: ' + id);
    throw new Error('Transition Published -> Draft is not allowed');
  }
}
const lifecycleService = new ArticleLifecycleService();


router.get('/', async (req, res) => {
  const q = req.query.q as string | undefined;
  const where = q ? { OR: [{ title: { contains: q } }, { excerpt: { contains: q } }] } : undefined;
  const items = await prisma.article.findMany(where ? { where } : undefined);
  res.json(items.map(applyProjection));
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
    if (body.language !== undefined) data.language = body.language;
    if (body.viewCount !== undefined) data.viewCount = body.viewCount;
    if (body.likesCount !== undefined) data.likesCount = body.likesCount;
    if (body.isFeatured !== undefined) data.isFeatured = body.isFeatured;
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
  try {
  validate(data);
    const entity = await prisma.article.create({ data });
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.article.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
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
    if (body.language !== undefined) data.language = body.language;
    if (body.viewCount !== undefined) data.viewCount = body.viewCount;
    if (body.likesCount !== undefined) data.likesCount = body.likesCount;
    if (body.isFeatured !== undefined) data.isFeatured = body.isFeatured;
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
  try {
  validate(data);
    const entity = await prisma.article.update({ where: { id: Number(req.params.id) }, data });
    res.json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
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
    if (body.language !== undefined) data.language = body.language;
    if (body.viewCount !== undefined) data.viewCount = body.viewCount;
    if (body.likesCount !== undefined) data.likesCount = body.likesCount;
    if (body.isFeatured !== undefined) data.isFeatured = body.isFeatured;
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.authorId !== undefined) data.authorId = body.authorId;
    if (body.featuredDeckId !== undefined) data.featuredDeckId = body.featuredDeckId;
  try {
  validate(data);
    const entity = await prisma.article.update({ where: { id: Number(req.params.id) }, data });
    res.json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
  }
});

router.post('/:id/publish', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.publish(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/archive', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.archive(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/view', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.increment_view(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/like', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.like(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.delete('/:id/like', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.unlike(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/reading-time', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.reading_time_minutes(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/transitions/draft-to-published', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionDraftToPublished(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/published-to-archived', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionPublishedToArchived(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/archived-to-draft', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionArchivedToDraft(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/published-to-draft', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionPublishedToDraft(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});
export default router;
