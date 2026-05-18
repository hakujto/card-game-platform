import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { CardRulingService } from '../../services/Cards/card_ruling_service.js';

const router = Router();
const service = new CardRulingService();


router.get('/', async (_req, res) => {
  const items = await prisma.cardRuling.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.rulingText !== undefined) data.rulingText = body.rulingText;
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.source !== undefined) data.source = body.source;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.cardRuling.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.cardRuling.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.rulingText !== undefined) data.rulingText = body.rulingText;
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.source !== undefined) data.source = body.source;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.cardRuling.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.rulingText !== undefined) data.rulingText = body.rulingText;
    if (body.publishedAt !== undefined) data.publishedAt = body.publishedAt != null ? new Date(body.publishedAt) : null;
    if (body.source !== undefined) data.source = body.source;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
    const entity = await prisma.cardRuling.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.cardRuling.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.get('/:id/current', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.is_current(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/supersedes', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.supersedes_previous(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
