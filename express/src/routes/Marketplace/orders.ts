import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { OrderService } from '../../services/Marketplace/order_service.js';

const router = Router();
const service = new OrderService();

function validate(data: any): void {
  if (!((data.total == null || Number(data.total) >= 0))) throw new Error(`Order total must not be negative`);
  if (!((data.discountApplied == null || (data.total != null && Number(data.discountApplied) <= Number(data.total))))) throw new Error(`Discount applied cannot exceed order total`);
  if ((data.status === 'PAID') && !((data.paidAt === undefined || data.paidAt != null))) throw new Error(`Paid order must have paid_at set`);
  if ((data.status === 'SHIPPED') && !((data.trackingNumber === undefined || data.trackingNumber != null))) throw new Error(`Shipped order must have a tracking number`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.order.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.total !== undefined) data.total = body.total;
    if (body.discountApplied !== undefined) data.discountApplied = body.discountApplied;
    if (body.currency !== undefined) data.currency = body.currency;
    if (body.paymentMethod !== undefined) data.paymentMethod = body.paymentMethod;
    if (body.paymentReference !== undefined) data.paymentReference = body.paymentReference;
    if (body.shippingAddress !== undefined) data.shippingAddress = body.shippingAddress;
    if (body.trackingNumber !== undefined) data.trackingNumber = body.trackingNumber;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.paidAt !== undefined) data.paidAt = body.paidAt != null ? new Date(body.paidAt) : null;
    if (body.shippedAt !== undefined) data.shippedAt = body.shippedAt != null ? new Date(body.shippedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.couponId !== undefined) data.couponId = body.couponId;
  try {
  validate(data);
    const entity = await prisma.order.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.order.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.total !== undefined) data.total = body.total;
    if (body.discountApplied !== undefined) data.discountApplied = body.discountApplied;
    if (body.currency !== undefined) data.currency = body.currency;
    if (body.paymentMethod !== undefined) data.paymentMethod = body.paymentMethod;
    if (body.paymentReference !== undefined) data.paymentReference = body.paymentReference;
    if (body.shippingAddress !== undefined) data.shippingAddress = body.shippingAddress;
    if (body.trackingNumber !== undefined) data.trackingNumber = body.trackingNumber;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.paidAt !== undefined) data.paidAt = body.paidAt != null ? new Date(body.paidAt) : null;
    if (body.shippedAt !== undefined) data.shippedAt = body.shippedAt != null ? new Date(body.shippedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.couponId !== undefined) data.couponId = body.couponId;
  try {
  validate(data);
    const entity = await prisma.order.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.total !== undefined) data.total = body.total;
    if (body.discountApplied !== undefined) data.discountApplied = body.discountApplied;
    if (body.currency !== undefined) data.currency = body.currency;
    if (body.paymentMethod !== undefined) data.paymentMethod = body.paymentMethod;
    if (body.paymentReference !== undefined) data.paymentReference = body.paymentReference;
    if (body.shippingAddress !== undefined) data.shippingAddress = body.shippingAddress;
    if (body.trackingNumber !== undefined) data.trackingNumber = body.trackingNumber;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.paidAt !== undefined) data.paidAt = body.paidAt != null ? new Date(body.paidAt) : null;
    if (body.shippedAt !== undefined) data.shippedAt = body.shippedAt != null ? new Date(body.shippedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.couponId !== undefined) data.couponId = body.couponId;
  try {
  validate(data);
    const entity = await prisma.order.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.order.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id/cancel', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.cancel(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/pay', async (req, res) => {
  const id = Number((req.params as any).id);
  const paymentRef = req.body.paymentRef;
  try {
    const result = await service.pay(id, paymentRef);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/total', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.calculate_total(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/discount', async (req, res) => {
  const id = Number((req.params as any).id);
  const percent = req.body.percent;
  try {
    const result = await service.apply_discount(id, percent);
    res.json({ result });
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
export default router;
