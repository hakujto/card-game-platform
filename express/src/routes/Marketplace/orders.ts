import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { OrderService } from '../../services/Marketplace/order_service.js';

const router = Router();
const service = new OrderService();

function validate(data: any): void {
  if (data.currency != null && !/[A-Z]{3}/.test(String(data.currency))) throw new Error('currency: invalid format');
  if ((data.status === 'Shipped') && data.trackingNumber == null) throw new Error('tracking_number is required');
  if ((data.status === 'Paid') && data.paidAt == null) throw new Error('paid_at is required');
  if (!((data.total == null || Number(data.total) >= 0))) throw new Error(`Order total must not be negative`);
  if (!((data.discountApplied == null || (data.total != null && Number(data.discountApplied) <= Number(data.total))))) throw new Error(`Discount applied cannot exceed order total`);
  if ((data.status === 'PAID') && !((data.paidAt === undefined || data.paidAt != null))) throw new Error(`Paid order must have paid_at set`);
  if ((data.status === 'SHIPPED') && !((data.trackingNumber === undefined || data.trackingNumber != null))) throw new Error(`Shipped order must have a tracking number`);
  if ((data.shippedAt != null) && !(data.status === 'SHIPPED')) throw new Error(`shipped_at_requires_shipped_status`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  delete r.paymentReference;
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('paidAt' in r) { r.paidAt = r.paidAt; delete r.paidAt; }
  if ('shippedAt' in r) { r.shippedAt = r.shippedAt; delete r.shippedAt; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Pending': ['Paid', 'Cancelled'],
  'Paid': ['Processing', 'Cancelled'],
  'Processing': ['Shipped'],
  'Shipped': ['Completed'],
  'Completed': ['Refunded']
};

function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

class OrderLifecycleService {

  async transitionPendingToPaid(id: number): Promise<any> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    assertTransition((entity as any).status, 'Paid');
    if ((entity as any).paymentMethod == null) throw new Error('payment_method is required for Pending -> Paid');
    const updated = await prisma.order.update({ where: { id }, data: { status: 'PAID' as any } });
    // TODO: entity.processPayment(); // @after
    return updated;
  }

  async transitionPaidToProcessing(id: number): Promise<any> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    assertTransition((entity as any).status, 'Processing');
    const updated = await prisma.order.update({ where: { id }, data: { status: 'PROCESSING' as any } });
    return updated;
  }

  async transitionProcessingToShipped(id: number): Promise<any> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    assertTransition((entity as any).status, 'Shipped');
    if ((entity as any).trackingNumber == null) throw new Error('tracking_number is required for Processing -> Shipped');
    const updated = await prisma.order.update({ where: { id }, data: { status: 'SHIPPED' as any } });
    // TODO: entity.notifyShipped(); // @after
    return updated;
  }

  async transitionShippedToCompleted(id: number): Promise<any> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    assertTransition((entity as any).status, 'Completed');
    const updated = await prisma.order.update({ where: { id }, data: { status: 'COMPLETED' as any } });
    return updated;
  }

  async transitionPendingToCancelled(id: number): Promise<any> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    assertTransition((entity as any).status, 'Cancelled');
    const updated = await prisma.order.update({ where: { id }, data: { status: 'CANCELLED' as any } });
    // TODO: entity.cancel(); // @after
    return updated;
  }

  async transitionPaidToCancelled(id: number): Promise<any> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    assertTransition((entity as any).status, 'Cancelled');
    const updated = await prisma.order.update({ where: { id }, data: { status: 'CANCELLED' as any } });
    // TODO: entity.cancel(); // @after
    return updated;
  }

  async transitionCompletedToRefunded(id: number): Promise<any> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    assertTransition((entity as any).status, 'Refunded');
    const updated = await prisma.order.update({ where: { id }, data: { status: 'REFUNDED' as any } });
    // TODO: entity.refund(); // @after
    return updated;
  }

  async transitionRefundedToCompleted(id: number): Promise<any> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    throw new Error('Transition Refunded -> Completed is not allowed');
  }

  async transitionCompletedToCancelled(id: number): Promise<any> {
    const entity = await prisma.order.findUnique({ where: { id } });
    if (!entity) throw new Error('Order not found: ' + id);
    throw new Error('Transition Completed -> Cancelled is not allowed');
  }
}
const lifecycleService = new OrderLifecycleService();


router.get('/', async (req, res) => {
  const items = await prisma.order.findMany();
  res.json(items.map(applyProjection));
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
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.order.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  if (entity.playerId !== (req as any).userId) return res.status(403).json({ error: 'You do not own this resource.' });
  res.json(applyProjection(entity));
});

router.delete('/:id/cancel', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.cancel(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/pay', async (req, res) => {
  const id = Number((req.params as any).id);
  const paymentRef = req.body.paymentRef;
  try {
    const result = await service.pay(id, paymentRef);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/process-payment', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.process_payment(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/total', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.calculate_total(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/discount', async (req, res) => {
  const id = Number((req.params as any).id);
  const percent = req.body.percent;
  try {
    const result = await service.apply_discount(id, percent);
    res.json({ result });
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

router.patch('/:id/transitions/pending-to-paid', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionPendingToPaid(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/paid-to-processing', async (req, res) => {
  const id = Number(req.params.id);
  const userRole = (req as any).user?.role;
  if (!['Admin', 'Staff'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for transition Paid -> Processing' }); return; }
  try {
    const entity = await lifecycleService.transitionPaidToProcessing(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/processing-to-shipped', async (req, res) => {
  const id = Number(req.params.id);
  const userRole = (req as any).user?.role;
  if (!['Admin', 'Staff'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for transition Processing -> Shipped' }); return; }
  try {
    const entity = await lifecycleService.transitionProcessingToShipped(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/shipped-to-completed', async (req, res) => {
  const id = Number(req.params.id);
  const userRole = (req as any).user?.role;
  if (!['Admin', 'Staff'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for transition Shipped -> Completed' }); return; }
  try {
    const entity = await lifecycleService.transitionShippedToCompleted(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/pending-to-cancelled', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionPendingToCancelled(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/paid-to-cancelled', async (req, res) => {
  const id = Number(req.params.id);
  const userRole = (req as any).user?.role;
  if (!['Admin', 'Staff'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for transition Paid -> Cancelled' }); return; }
  try {
    const entity = await lifecycleService.transitionPaidToCancelled(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/completed-to-refunded', async (req, res) => {
  const id = Number(req.params.id);
  const userRole = (req as any).user?.role;
  if (!['Admin'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for transition Completed -> Refunded' }); return; }
  try {
    const entity = await lifecycleService.transitionCompletedToRefunded(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/refunded-to-completed', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionRefundedToCompleted(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/completed-to-cancelled', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionCompletedToCancelled(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});
export default router;
