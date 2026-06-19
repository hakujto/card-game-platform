import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { AchievementService } from '../../services/Players/achievement_service.js';

const router = Router();
const service = new AchievementService();

function validate(data: any): void {
  if (!((data.points == null || data.points > 0))) throw new Error(`Achievement must award at least one point`);
}

router.get('/', async (req, res) => {
  const q = req.query.q as string | undefined;
  const where = q ? { OR: [{ name: { contains: q } }, { description: { contains: q } }] } : undefined;
  const items = await prisma.achievement.findMany(where ? { where } : undefined);
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.iconUrl !== undefined) data.iconUrl = body.iconUrl;
    if (body.points !== undefined) data.points = body.points;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
  try {
  validate(data);
    const entity = await prisma.achievement.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.achievement.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.iconUrl !== undefined) data.iconUrl = body.iconUrl;
    if (body.points !== undefined) data.points = body.points;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
  try {
  validate(data);
    const existing = await prisma.achievement.findUnique({ where: { id: Number(req.params.id) } });
    if (!existing) return res.status(404).json({ error: 'Not found' });
    const entity = await prisma.achievement.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.iconUrl !== undefined) data.iconUrl = body.iconUrl;
    if (body.points !== undefined) data.points = body.points;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.isHidden !== undefined) data.isHidden = body.isHidden;
  try {
  validate(data);
    const existing = await prisma.achievement.findUnique({ where: { id: Number(req.params.id) } });
    if (!existing) return res.status(404).json({ error: 'Not found' });
    const entity = await prisma.achievement.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
  }
});

router.get('/:id/point-value', async (req, res) => {
  const id = Number((req.params as any).id);
  const multiplier = (req.query as any).multiplier;
  try {
    const result = await service.point_value(id, multiplier);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/reveal', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.reveal(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
