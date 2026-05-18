import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { FriendshipService } from '../../services/Players/friendship_service.js';

const router = Router();
const service = new FriendshipService();


router.get('/', async (_req, res) => {
  const items = await prisma.friendship.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.requesterId !== undefined) data.requesterId = body.requesterId;
    if (body.receiverId !== undefined) data.receiverId = body.receiverId;
  try {
    const entity = await prisma.friendship.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.friendship.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.requesterId !== undefined) data.requesterId = body.requesterId;
    if (body.receiverId !== undefined) data.receiverId = body.receiverId;
  try {
    const entity = await prisma.friendship.update({ where: { id: Number(req.params.id) }, data });
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
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.requesterId !== undefined) data.requesterId = body.requesterId;
    if (body.receiverId !== undefined) data.receiverId = body.receiverId;
  try {
    const entity = await prisma.friendship.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.friendship.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/accept', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.accept(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/decline', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.decline(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/block', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.block(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
