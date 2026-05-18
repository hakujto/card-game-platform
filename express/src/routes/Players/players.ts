import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { PlayerService } from '../../services/Players/player_service.js';

const router = Router();
const service = new PlayerService();

function validate(data: any): void {
  if (!((data.rating == null || (data.rating >= 0 && data.rating <= 9999)))) throw new Error(`Rating must be between 0 and 9999`);
  if (!((data.peakRating == null || (data.rating != null && data.peakRating >= data.rating)))) throw new Error(`Peak rating must be greater than or equal to current rating`);
  if (!((data.displayName === undefined || data.displayName != null))) throw new Error(`Display name must not be empty`);
}

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
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.lastActiveAt !== undefined) data.lastActiveAt = body.lastActiveAt != null ? new Date(body.lastActiveAt) : null;
    if (body.userId !== undefined) data.userId = body.userId;
  try {
  validate(data);
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
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.lastActiveAt !== undefined) data.lastActiveAt = body.lastActiveAt != null ? new Date(body.lastActiveAt) : null;
    if (body.userId !== undefined) data.userId = body.userId;
  try {
  validate(data);
    const entity = await prisma.player.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.lastActiveAt !== undefined) data.lastActiveAt = body.lastActiveAt != null ? new Date(body.lastActiveAt) : null;
    if (body.userId !== undefined) data.userId = body.userId;
  try {
  validate(data);
    const entity = await prisma.player.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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

router.post('/:id/promote', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.promote(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/demote', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.demote(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/win', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.record_win(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/loss', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.record_loss(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/win-rate', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.win_rate(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/verify', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.verify(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/rating', async (req, res) => {
  const id = Number((req.params as any).id);
  const delta = req.body.delta;
  try {
    await service.update_rating(id, delta);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
