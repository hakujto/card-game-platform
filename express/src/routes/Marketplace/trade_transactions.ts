import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TradeTransactionService } from '../../services/Marketplace/trade_transaction_service.js';

const router = Router();
const service = new TradeTransactionService();

function validate(data: any): void {
  if (!((data.platformFee == null || (data.finalPrice != null && Number(data.platformFee) <= Number(data.finalPrice))))) throw new Error(`Platform fee cannot exceed the final price`);
  if (!((data.platformFee == null || Number(data.platformFee) >= 0))) throw new Error(`Platform fee must not be negative`);
  if (!((data.finalPrice == null || Number(data.finalPrice) > 0))) throw new Error(`Transaction final price must be greater than zero`);
  if ((data.status === 'COMPLETED') && !((data.completedAt === undefined || data.completedAt != null))) throw new Error(`Completed transaction must have a completed_at timestamp`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.tradeTransaction.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.finalPrice !== undefined) data.finalPrice = body.finalPrice;
    if (body.platformFee !== undefined) data.platformFee = body.platformFee;
    if (body.status !== undefined) data.status = body.status;
    if (body.completedAt !== undefined) data.completedAt = body.completedAt != null ? new Date(body.completedAt) : null;
    if (body.listingId !== undefined) data.listingId = body.listingId;
    if (body.buyerId !== undefined) data.buyerId = body.buyerId;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
  try {
  validate(data);
    const entity = await prisma.tradeTransaction.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tradeTransaction.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.finalPrice !== undefined) data.finalPrice = body.finalPrice;
    if (body.platformFee !== undefined) data.platformFee = body.platformFee;
    if (body.status !== undefined) data.status = body.status;
    if (body.completedAt !== undefined) data.completedAt = body.completedAt != null ? new Date(body.completedAt) : null;
    if (body.listingId !== undefined) data.listingId = body.listingId;
    if (body.buyerId !== undefined) data.buyerId = body.buyerId;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
  try {
  validate(data);
    const entity = await prisma.tradeTransaction.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.finalPrice !== undefined) data.finalPrice = body.finalPrice;
    if (body.platformFee !== undefined) data.platformFee = body.platformFee;
    if (body.status !== undefined) data.status = body.status;
    if (body.completedAt !== undefined) data.completedAt = body.completedAt != null ? new Date(body.completedAt) : null;
    if (body.listingId !== undefined) data.listingId = body.listingId;
    if (body.buyerId !== undefined) data.buyerId = body.buyerId;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
  try {
  validate(data);
    const entity = await prisma.tradeTransaction.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.tradeTransaction.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
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

router.post('/:id/refund', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.refund(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/dispute', async (req, res) => {
  const id = Number((req.params as any).id);
  const reason = req.body.reason;
  try {
    await service.open_dispute(id, reason);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/seller-net', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.seller_net(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
