import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.player.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.displayName !== undefined) data.displayName = body.displayName;
    if (body.rank !== undefined) data.rank = body.rank;
    if (body.rating !== undefined) data.rating = body.rating;
    if (body.peakRating !== undefined) data.peakRating = body.peakRating;
    if (body.bio !== undefined) data.bio = body.bio;
    if (body.countryCode !== undefined) data.countryCode = body.countryCode;
    if (body.avatarUrl !== undefined) data.avatarUrl = body.avatarUrl;
    if (body.preferredFormat !== undefined) data.preferredFormat = body.preferredFormat;
    if (body.isVerified !== undefined) data.isVerified = body.isVerified;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.lastActiveAt !== undefined) data.lastActiveAt = new Date(body.lastActiveAt);
    if (body.userId !== undefined) data.userId = body.userId;
    if (body.seasonStatsId !== undefined) data.seasonStatsId = body.seasonStatsId;
  try {
    const entity = await prisma.player.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.player.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.displayName !== undefined) data.displayName = body.displayName;
    if (body.rank !== undefined) data.rank = body.rank;
    if (body.rating !== undefined) data.rating = body.rating;
    if (body.peakRating !== undefined) data.peakRating = body.peakRating;
    if (body.bio !== undefined) data.bio = body.bio;
    if (body.countryCode !== undefined) data.countryCode = body.countryCode;
    if (body.avatarUrl !== undefined) data.avatarUrl = body.avatarUrl;
    if (body.preferredFormat !== undefined) data.preferredFormat = body.preferredFormat;
    if (body.isVerified !== undefined) data.isVerified = body.isVerified;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.lastActiveAt !== undefined) data.lastActiveAt = new Date(body.lastActiveAt);
    if (body.userId !== undefined) data.userId = body.userId;
    if (body.seasonStatsId !== undefined) data.seasonStatsId = body.seasonStatsId;
  try {
    const entity = await prisma.player.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.displayName !== undefined) data.displayName = body.displayName;
    if (body.rank !== undefined) data.rank = body.rank;
    if (body.rating !== undefined) data.rating = body.rating;
    if (body.peakRating !== undefined) data.peakRating = body.peakRating;
    if (body.bio !== undefined) data.bio = body.bio;
    if (body.countryCode !== undefined) data.countryCode = body.countryCode;
    if (body.avatarUrl !== undefined) data.avatarUrl = body.avatarUrl;
    if (body.preferredFormat !== undefined) data.preferredFormat = body.preferredFormat;
    if (body.isVerified !== undefined) data.isVerified = body.isVerified;
    if (body.createdAt !== undefined) data.createdAt = new Date(body.createdAt);
    if (body.lastActiveAt !== undefined) data.lastActiveAt = new Date(body.lastActiveAt);
    if (body.userId !== undefined) data.userId = body.userId;
    if (body.seasonStatsId !== undefined) data.seasonStatsId = body.seasonStatsId;
  try {
    const entity = await prisma.player.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.player.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
