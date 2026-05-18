import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { SeasonService } from '../../services/Tournaments/season_service.js';

const router = Router();
const service = new SeasonService();

function validate(data: any): void {
  if (!((data.endDate == null || (data.startDate != null && data.endDate > data.startDate)))) throw new Error(`Season end date must be after start date`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.season.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.startDate !== undefined) data.startDate = body.startDate != null ? new Date(body.startDate) : null;
    if (body.endDate !== undefined) data.endDate = body.endDate != null ? new Date(body.endDate) : null;
    if (body.format !== undefined) data.format = body.format;
    if (body.isActive !== undefined) data.isActive = body.isActive;
    if (body.rewardDescription !== undefined) data.rewardDescription = body.rewardDescription;
  try {
  validate(data);
    const entity = await prisma.season.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.season.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.startDate !== undefined) data.startDate = body.startDate != null ? new Date(body.startDate) : null;
    if (body.endDate !== undefined) data.endDate = body.endDate != null ? new Date(body.endDate) : null;
    if (body.format !== undefined) data.format = body.format;
    if (body.isActive !== undefined) data.isActive = body.isActive;
    if (body.rewardDescription !== undefined) data.rewardDescription = body.rewardDescription;
  try {
  validate(data);
    const entity = await prisma.season.update({ where: { id: Number(req.params.id) }, data });
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
    if (body.startDate !== undefined) data.startDate = body.startDate != null ? new Date(body.startDate) : null;
    if (body.endDate !== undefined) data.endDate = body.endDate != null ? new Date(body.endDate) : null;
    if (body.format !== undefined) data.format = body.format;
    if (body.isActive !== undefined) data.isActive = body.isActive;
    if (body.rewardDescription !== undefined) data.rewardDescription = body.rewardDescription;
  try {
  validate(data);
    const entity = await prisma.season.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.season.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/activate', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.activate(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/deactivate', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.deactivate(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/finalize', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.finalize_rewards(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/ongoing', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.is_ongoing(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
