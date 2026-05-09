import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

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
    if (body.auctionEndTime !== undefined) data.auctionEndTime = new Date(body.auctionEndTime);
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.status !== undefined) data.status = body.status;
    if (body.description !== undefined) data.description = body.description;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.expiresAt !== undefined) data.expiresAt = new Date(body.expiresAt);
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.bidsId !== undefined) data.bidsId = body.bidsId;
  try {
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
    if (body.auctionEndTime !== undefined) data.auctionEndTime = new Date(body.auctionEndTime);
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.status !== undefined) data.status = body.status;
    if (body.description !== undefined) data.description = body.description;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.expiresAt !== undefined) data.expiresAt = new Date(body.expiresAt);
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.bidsId !== undefined) data.bidsId = body.bidsId;
  try {
    const entity = await prisma.tradelisting.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.listingType !== undefined) data.listingType = body.listingType;
    if (body.askingPrice !== undefined) data.askingPrice = body.askingPrice;
    if (body.auctionStartPrice !== undefined) data.auctionStartPrice = body.auctionStartPrice;
    if (body.auctionCurrentBid !== undefined) data.auctionCurrentBid = body.auctionCurrentBid;
    if (body.auctionEndTime !== undefined) data.auctionEndTime = new Date(body.auctionEndTime);
    if (body.foil !== undefined) data.foil = body.foil;
    if (body.condition !== undefined) data.condition = body.condition;
    if (body.quantity !== undefined) data.quantity = body.quantity;
    if (body.status !== undefined) data.status = body.status;
    if (body.description !== undefined) data.description = body.description;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.expiresAt !== undefined) data.expiresAt = new Date(body.expiresAt);
    if (body.sellerId !== undefined) data.sellerId = body.sellerId;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.bidsId !== undefined) data.bidsId = body.bidsId;
  try {
    const entity = await prisma.tradelisting.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
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

export default router;
