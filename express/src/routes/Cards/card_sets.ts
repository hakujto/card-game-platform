import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { CardSetService } from '../../services/Cards/card_set_service.js';

const router = Router();
const service = new CardSetService();

function validate(data: any): void {
  if (!((data.totalCards == null || data.totalCards > 0))) throw new Error(`Card set must have at least one card`);
  if ((data.rotationDate != null) && !((data.rotationDate == null || (data.releaseDate != null && data.rotationDate > data.releaseDate)))) throw new Error(`Rotation date must be after release date`);
  if ((data.isRotated === true) && !((data.rotationDate === undefined || data.rotationDate != null))) throw new Error(`Rotated set must have a rotation date`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.cardSet.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.code !== undefined) data.code = body.code;
    if (body.releaseDate !== undefined) data.releaseDate = body.releaseDate != null ? new Date(body.releaseDate) : null;
    if (body.rotationDate !== undefined) data.rotationDate = body.rotationDate != null ? new Date(body.rotationDate) : null;
    if (body.setType !== undefined) data.setType = body.setType;
    if (body.totalCards !== undefined) data.totalCards = body.totalCards;
    if (body.isRotated !== undefined) data.isRotated = body.isRotated;
    if (body.description !== undefined) data.description = body.description;
    if (body.logoUrl !== undefined) data.logoUrl = body.logoUrl;
  try {
  validate(data);
    const entity = await prisma.cardSet.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.cardSet.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.code !== undefined) data.code = body.code;
    if (body.releaseDate !== undefined) data.releaseDate = body.releaseDate != null ? new Date(body.releaseDate) : null;
    if (body.rotationDate !== undefined) data.rotationDate = body.rotationDate != null ? new Date(body.rotationDate) : null;
    if (body.setType !== undefined) data.setType = body.setType;
    if (body.totalCards !== undefined) data.totalCards = body.totalCards;
    if (body.isRotated !== undefined) data.isRotated = body.isRotated;
    if (body.description !== undefined) data.description = body.description;
    if (body.logoUrl !== undefined) data.logoUrl = body.logoUrl;
  try {
  validate(data);
    const entity = await prisma.cardSet.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.code !== undefined) data.code = body.code;
    if (body.releaseDate !== undefined) data.releaseDate = body.releaseDate != null ? new Date(body.releaseDate) : null;
    if (body.rotationDate !== undefined) data.rotationDate = body.rotationDate != null ? new Date(body.rotationDate) : null;
    if (body.setType !== undefined) data.setType = body.setType;
    if (body.totalCards !== undefined) data.totalCards = body.totalCards;
    if (body.isRotated !== undefined) data.isRotated = body.isRotated;
    if (body.description !== undefined) data.description = body.description;
    if (body.logoUrl !== undefined) data.logoUrl = body.logoUrl;
  try {
  validate(data);
    const entity = await prisma.cardSet.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.cardSet.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.get('/:id/standard-legal', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.is_legal_in_standard(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/legal', async (req, res) => {
  const id = Number((req.params as any).id);
  const format = (req.query as any).format;
  try {
    const result = await service.is_legal_in_format(id, format);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/rarity-count', async (req, res) => {
  const id = Number((req.params as any).id);
  const rarity = (req.query as any).rarity;
  try {
    const result = await service.card_count_by_rarity(id, rarity);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/rotate', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.rotate_out(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
