import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { PlayerAchievementService } from '../../services/Players/player_achievement_service.js';

const router = Router();
const service = new PlayerAchievementService();

function validate(data: any): void {
  if (!((data.progress == null || data.progress >= 0))) throw new Error(`Achievement progress must not be negative`);
  if ((data.isCompleted === true) && !((data.progress == null || data.progress > 0))) throw new Error(`Completed achievement must have progress greater than zero`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('earnedAt' in r) { r.earnedAt = r.earnedAt; delete r.earnedAt; }
  return r;
}


router.get('/', async (req, res) => {
  const items = await prisma.playerAchievement.findMany();
  res.json(items.map(applyProjection));
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.playerAchievement.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
});

router.patch('/:id/progress', async (req, res) => {
  const id = Number((req.params as any).id);
  const amount = req.body.amount;
  try {
    await service.increment_progress(id, amount);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/complete', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.complete(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
