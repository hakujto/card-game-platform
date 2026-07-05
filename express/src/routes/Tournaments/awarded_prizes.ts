import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { AwardedPrizeService } from '../../services/Tournaments/awarded_prize_service.js';

const router = Router();
const service = new AwardedPrizeService();

function validate(data: any): void {
  if ((data.claimed === true) && data.claimedAt == null) throw new Error('claimed_at is required');
  if (!((data.finalPlacement == null || data.finalPlacement > 0))) throw new Error(`Final placement must be greater than zero`);
  if ((data.claimed === true) && !((data.claimedAt === undefined || data.claimedAt != null))) throw new Error(`Claimed prize must have a claimed_at timestamp`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('awardedAt' in r) { r.awardedAt = r.awardedAt; delete r.awardedAt; }
  if ('claimedAt' in r) { r.claimedAt = r.claimedAt; delete r.claimedAt; }
  return r;
}


router.get('/', async (req, res) => {
  const items = await prisma.awardedPrize.findMany();
  res.json(items.map(applyProjection));
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.awardedPrize.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
});

router.post('/:id/claim', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.claim(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
