import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TradeBidService } from '../../services/Marketplace/trade_bid_service.js';

const router = Router();
const service = new TradeBidService();

function validate(data: any): void {
  if (!((data.amount == null || Number(data.amount) > 0))) throw new Error(`Bid amount must be greater than zero`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('placedAt' in r) { r.placedAt = r.placedAt; delete r.placedAt; }
  return r;
}


router.get('/', async (req, res) => {
  const items = await prisma.tradeBid.findMany();
  res.json(items.map(applyProjection));
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.amount !== undefined) data.amount = body.amount;
    if (body.placedAt !== undefined) data.placedAt = body.placedAt != null ? new Date(body.placedAt) : null;
    if (body.isWinning !== undefined) data.isWinning = body.isWinning;
    if (body.listingId !== undefined) data.listingId = body.listingId;
    if (body.bidderId !== undefined) data.bidderId = body.bidderId;
  try {
  validate(data);
    const entity = await prisma.tradeBid.create({ data });
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tradeBid.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
});

router.get('/:id/outbid', async (req, res) => {
  const id = Number((req.params as any).id);
  const newAmount = (req.query as any).newAmount;
  try {
    const result = await service.outbid_by(id, newAmount);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.retract(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
