import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TradeTransactionService } from '../../services/Marketplace/trade_transaction_service.js';

const router = Router();
const service = new TradeTransactionService();

function validate(data: any): void {
  if ((data.status === 'Completed') && data.completedAt == null) throw new Error('completed_at is required');
  if (!((data.platformFee == null || (data.finalPrice != null && Number(data.platformFee) <= Number(data.finalPrice))))) throw new Error(`Platform fee cannot exceed the final price`);
  if (!((data.platformFee == null || Number(data.platformFee) >= 0))) throw new Error(`Platform fee must not be negative`);
  if (!((data.finalPrice == null || Number(data.finalPrice) > 0))) throw new Error(`Transaction final price must be greater than zero`);
  if ((data.status === 'COMPLETED') && !((data.completedAt === undefined || data.completedAt != null))) throw new Error(`Completed transaction must have a completed_at timestamp`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('completedAt' in r) { r.completedAt = r.completedAt; delete r.completedAt; }
  return r;
}


router.get('/', async (req, res) => {
  const items = await prisma.tradeTransaction.findMany();
  res.json(items.map(applyProjection));
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tradeTransaction.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
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

router.post('/:id/refund', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.refund(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/dispute', async (req, res) => {
  const id = Number((req.params as any).id);
  const reason = req.body.reason;
  try {
    await service.open_dispute(id, reason);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/seller-net', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.seller_net(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
