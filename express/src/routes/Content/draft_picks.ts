import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { DraftPickService } from '../../services/Content/draft_pick_service.js';

const router = Router();
const service = new DraftPickService();

function validate(data: any): void {
  if (!((data.pickNumber == null || data.pickNumber > 0))) throw new Error(`Pick number must be greater than zero`);
  if (!((data.packNumber == null || (data.packNumber >= 1 && data.packNumber <= 3)))) throw new Error(`Pack number must be between 1 and 3`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('pickedAt' in r) { r.pickedAt = r.pickedAt; delete r.pickedAt; }
  return r;
}


router.get('/', async (req, res) => {
  const items = await prisma.draftPick.findMany();
  res.json(items.map(applyProjection));
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.draftPick.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
});

router.get('/:id/first-pick', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.is_first_pick(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
