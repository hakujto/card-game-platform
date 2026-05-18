import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { PlayerAchievementService } from '../../services/Players/player_achievement_service.js';

const router = Router();
const service = new PlayerAchievementService();

function validate(data: any): void {
  if (!((data.progress == null || data.progress >= 0))) throw new Error(`Achievement progress must not be negative`);
  if ((data.isCompleted === true) && !((data.progress == null || data.progress > 0))) throw new Error(`Completed achievement must have progress greater than zero`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.playerAchievement.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.earnedAt !== undefined) data.earnedAt = body.earnedAt != null ? new Date(body.earnedAt) : null;
    if (body.progress !== undefined) data.progress = body.progress;
    if (body.isCompleted !== undefined) data.isCompleted = body.isCompleted;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.achievementId !== undefined) data.achievementId = body.achievementId;
  try {
  validate(data);
    const entity = await prisma.playerAchievement.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.playerAchievement.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.earnedAt !== undefined) data.earnedAt = body.earnedAt != null ? new Date(body.earnedAt) : null;
    if (body.progress !== undefined) data.progress = body.progress;
    if (body.isCompleted !== undefined) data.isCompleted = body.isCompleted;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.achievementId !== undefined) data.achievementId = body.achievementId;
  try {
  validate(data);
    const entity = await prisma.playerAchievement.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.earnedAt !== undefined) data.earnedAt = body.earnedAt != null ? new Date(body.earnedAt) : null;
    if (body.progress !== undefined) data.progress = body.progress;
    if (body.isCompleted !== undefined) data.isCompleted = body.isCompleted;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.achievementId !== undefined) data.achievementId = body.achievementId;
  try {
  validate(data);
    const entity = await prisma.playerAchievement.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.playerAchievement.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id/progress', async (req, res) => {
  const id = Number((req.params as any).id);
  const amount = req.body.amount;
  try {
    await service.increment_progress(id, amount);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/complete', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.complete(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
