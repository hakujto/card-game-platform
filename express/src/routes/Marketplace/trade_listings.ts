import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TradeListingService } from '../../services/Marketplace/trade_listing_service.js';

const router = Router();
const service = new TradeListingService();

function validate(data: any): void {
  if (!((data.quantity == null || (data.quantity >= 1 && data.quantity <= 9999)))) throw new Error(`Listing quantity must be between 1 and 9999`);
  if ((data.listingType === 'FIXEDPRICE') && !((data.askingPrice === undefined || data.askingPrice != null))) throw new Error(`Fixed price listing must have an asking price`);
  if ((data.listingType === 'AUCTION') && !((data.auctionStartPrice === undefined || data.auctionStartPrice != null) && (data.auctionEndTime === undefined || data.auctionEndTime != null))) throw new Error(`Auction listing must have a start price and end time`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('expiresAt' in r) { r.expiresAt = r.expiresAt; delete r.expiresAt; }
  if ('auctionEndTime' in r) { r.auctionEndTime = r.auctionEndTime; delete r.auctionEndTime; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Pending': ['Active'],
  'Active': ['Sold', 'Expired', 'Cancelled']
};

function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

class TradeListingLifecycleService {

  async transitionPendingToActive(id: number): Promise<any> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    assertTransition((entity as any).status, 'Active');
    if ((entity as any).quantity == null) throw new Error('quantity is required for Pending -> Active');
    const updated = await prisma.tradeListing.update({ where: { id }, data: { status: 'ACTIVE' as any } });
    return updated;
  }

  async transitionActiveToSold(id: number): Promise<any> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    assertTransition((entity as any).status, 'Sold');
    const updated = await prisma.tradeListing.update({ where: { id }, data: { status: 'SOLD' as any } });
    // TODO: entity.finalizeAuction(); // @after
    return updated;
  }

  async transitionActiveToExpired(id: number): Promise<any> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    assertTransition((entity as any).status, 'Expired');
    const updated = await prisma.tradeListing.update({ where: { id }, data: { status: 'EXPIRED' as any } });
    // TODO: entity.close(); // @after
    return updated;
  }

  async transitionActiveToCancelled(id: number): Promise<any> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    assertTransition((entity as any).status, 'Cancelled');
    const updated = await prisma.tradeListing.update({ where: { id }, data: { status: 'CANCELLED' as any } });
    // TODO: entity.cancel(); // @after
    return updated;
  }

  async transitionSoldToActive(id: number): Promise<any> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    throw new Error('Transition Sold -> Active is not allowed');
  }

  async transitionExpiredToActive(id: number): Promise<any> {
    const entity = await prisma.tradeListing.findUnique({ where: { id } });
    if (!entity) throw new Error('TradeListing not found: ' + id);
    throw new Error('Transition Expired -> Active is not allowed');
  }
}
const lifecycleService = new TradeListingLifecycleService();


router.get('/', async (req, res) => {
  const q = req.query.q as string | undefined;
  const where = q ? { OR: [{ description: { contains: q } }] } : undefined;
  const items = await prisma.tradeListing.findMany(where ? { where } : undefined);
  res.json(items.map(applyProjection));
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.listingType !== undefined) data.listingType = body.listingType;
    if (body.askingPrice !== undefined) data.askingPrice = body.askingPrice;
    if (body.auctionStartPrice !== undefined) data.auctionStartPrice = body.auctionStartPrice;
    if (body.auctionCurrentBid !== undefined) data.auctionCurrentBid = body.auctionCurrentBid;
    if (body.auctionEndTime !== undefined) data.auctionEndTime = body.auctionEndTime != null ? new Date(body.auctionEndTime) : null;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.description !== undefined) data.description = body.description;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.expiresAt !== undefined) data.expiresAt = body.expiresAt != null ? new Date(body.expiresAt) : null;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.tradeListing.create({ data });
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tradeListing.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.listingType !== undefined) data.listingType = body.listingType;
    if (body.askingPrice !== undefined) data.askingPrice = body.askingPrice;
    if (body.auctionStartPrice !== undefined) data.auctionStartPrice = body.auctionStartPrice;
    if (body.auctionCurrentBid !== undefined) data.auctionCurrentBid = body.auctionCurrentBid;
    if (body.auctionEndTime !== undefined) data.auctionEndTime = body.auctionEndTime != null ? new Date(body.auctionEndTime) : null;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.description !== undefined) data.description = body.description;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.expiresAt !== undefined) data.expiresAt = body.expiresAt != null ? new Date(body.expiresAt) : null;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const existing = await prisma.tradeListing.findUnique({ where: { id: Number(req.params.id) } });
    if (!existing) return res.status(404).json({ error: 'Not found' });
    const entity = await prisma.tradeListing.update({ where: { id: Number(req.params.id) }, data });
    res.json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
  }
});

router.post('/:id/close', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.close(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/extend', async (req, res) => {
  const id = Number((req.params as any).id);
  const days = req.body.days;
  try {
    await service.extend(id, days);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
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

router.get('/:id/expired', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.is_expired(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/finalize', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.finalize_auction(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/transitions/pending-to-active', async (req, res) => {
  const id = Number(req.params.id);
  const userRole = (req as any).user?.role;
  if (!['Seller'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for transition Pending -> Active' }); return; }
  try {
    const entity = await lifecycleService.transitionPendingToActive(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/active-to-sold', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionActiveToSold(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/active-to-expired', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionActiveToExpired(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/active-to-cancelled', async (req, res) => {
  const id = Number(req.params.id);
  const userRole = (req as any).user?.role;
  if (!['Seller', 'Admin'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for transition Active -> Cancelled' }); return; }
  try {
    const entity = await lifecycleService.transitionActiveToCancelled(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/sold-to-active', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionSoldToActive(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/expired-to-active', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionExpiredToActive(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});
export default router;
