import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { CouponService } from '../../services/Marketplace/coupon_service.js';

const router = Router();
const service = new CouponService();

function validate(data: any): void {
  if (!((data.validUntil == null || (data.validFrom != null && data.validUntil > data.validFrom)))) throw new Error(`Coupon expiry must be after its start date`);
  if (!((data.discountValue == null || Number(data.discountValue) > 0))) throw new Error(`Discount value must be greater than zero`);
  if ((data.discountType === 'PERCENT') && !((data.discountValue == null || (data.discountValue >= 1 && data.discountValue <= 100)))) throw new Error(`Percent discount must be between 1 and 100`);
  if ((data.maxUses != null) && !((data.usesCount == null || (data.maxUses != null && data.usesCount <= data.maxUses)))) throw new Error(`Coupon uses count cannot exceed max_uses`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.coupon.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.code !== undefined) data.code = body.code;
    if (body.discountType !== undefined) data.discountType = body.discountType;
    if (body.discountValue !== undefined) data.discountValue = body.discountValue;
    if (body.minOrderValue !== undefined) data.minOrderValue = body.minOrderValue;
    if (body.maxUses !== undefined) data.maxUses = body.maxUses;
    if (body.usesCount !== undefined) data.usesCount = body.usesCount;
    if (body.validFrom !== undefined) data.validFrom = body.validFrom != null ? new Date(body.validFrom) : null;
    if (body.validUntil !== undefined) data.validUntil = body.validUntil != null ? new Date(body.validUntil) : null;
    if (body.isActive !== undefined) data.isActive = body.isActive;
  try {
  validate(data);
    const entity = await prisma.coupon.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.coupon.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.code !== undefined) data.code = body.code;
    if (body.discountType !== undefined) data.discountType = body.discountType;
    if (body.discountValue !== undefined) data.discountValue = body.discountValue;
    if (body.minOrderValue !== undefined) data.minOrderValue = body.minOrderValue;
    if (body.maxUses !== undefined) data.maxUses = body.maxUses;
    if (body.usesCount !== undefined) data.usesCount = body.usesCount;
    if (body.validFrom !== undefined) data.validFrom = body.validFrom != null ? new Date(body.validFrom) : null;
    if (body.validUntil !== undefined) data.validUntil = body.validUntil != null ? new Date(body.validUntil) : null;
    if (body.isActive !== undefined) data.isActive = body.isActive;
  try {
  validate(data);
    const entity = await prisma.coupon.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.code !== undefined) data.code = body.code;
    if (body.discountType !== undefined) data.discountType = body.discountType;
    if (body.discountValue !== undefined) data.discountValue = body.discountValue;
    if (body.minOrderValue !== undefined) data.minOrderValue = body.minOrderValue;
    if (body.maxUses !== undefined) data.maxUses = body.maxUses;
    if (body.usesCount !== undefined) data.usesCount = body.usesCount;
    if (body.validFrom !== undefined) data.validFrom = body.validFrom != null ? new Date(body.validFrom) : null;
    if (body.validUntil !== undefined) data.validUntil = body.validUntil != null ? new Date(body.validUntil) : null;
    if (body.isActive !== undefined) data.isActive = body.isActive;
  try {
  validate(data);
    const entity = await prisma.coupon.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.coupon.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/redeem', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.redeem(id);
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
export default router;
