import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { TradelistingService } from '../../services/Marketplace/tradelisting_service.js';

const router = Router();
const service = new TradelistingService();

function validate(data: any): void {
  if (!((data.quantity == null || (data.quantity >= 1 && data.quantity <= 9999)))) throw new Error(`Listing quantity must be between 1 and 9999`);
  if ((data.listingType === 'FIXEDPRICE') && !((data.askingPrice === undefined || data.askingPrice != null))) throw new Error(`Fixed price listing must have an asking price`);
  if ((data.listingType === 'AUCTION') && !((data.auctionStartPrice === undefined || data.auctionStartPrice != null) && (data.auctionEndTime === undefined || data.auctionEndTime != null))) throw new Error(`Auction listing must have a start price and end time`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.tradelisting.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.listingType !== undefined) data.listingType = body.listingType;
    if (body.askingPrice !== undefined) data.askingPrice = body.askingPrice;
    if (body.auctionStartPrice !== undefined) data.auctionStartPrice = body.auctionStartPrice;
    if (body.auctionCurrentBid !== undefined) data.auctionCurrentBid = body.auctionCurrentBid;
    if (body.auctionEndTime !== undefined) data.auctionEndTime = body.auctionEndTime != null ? new Date(body.auctionEndTime) : null;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.status !== undefined) data.status = body.status;
    if (body.description !== undefined) data.description = body.description;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.expiresAt !== undefined) data.expiresAt = body.expiresAt != null ? new Date(body.expiresAt) : null;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.tradelisting.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.tradelisting.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.listingType !== undefined) data.listingType = body.listingType;
    if (body.askingPrice !== undefined) data.askingPrice = body.askingPrice;
    if (body.auctionStartPrice !== undefined) data.auctionStartPrice = body.auctionStartPrice;
    if (body.auctionCurrentBid !== undefined) data.auctionCurrentBid = body.auctionCurrentBid;
    if (body.auctionEndTime !== undefined) data.auctionEndTime = body.auctionEndTime != null ? new Date(body.auctionEndTime) : null;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.status !== undefined) data.status = body.status;
    if (body.description !== undefined) data.description = body.description;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.expiresAt !== undefined) data.expiresAt = body.expiresAt != null ? new Date(body.expiresAt) : null;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.tradelisting.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.listingType !== undefined) data.listingType = body.listingType;
    if (body.askingPrice !== undefined) data.askingPrice = body.askingPrice;
    if (body.auctionStartPrice !== undefined) data.auctionStartPrice = body.auctionStartPrice;
    if (body.auctionCurrentBid !== undefined) data.auctionCurrentBid = body.auctionCurrentBid;
    if (body.auctionEndTime !== undefined) data.auctionEndTime = body.auctionEndTime != null ? new Date(body.auctionEndTime) : null;
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.status !== undefined) data.status = body.status;
    if (body.description !== undefined) data.description = body.description;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.expiresAt !== undefined) data.expiresAt = body.expiresAt != null ? new Date(body.expiresAt) : null;
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.tradelisting.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.tradelisting.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/close', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.close(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/extend', async (req, res) => {
  const id = Number((req.params as any).id);
  const days = req.body.days;
  try {
    await service.extend(id, days);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
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
export default router;
