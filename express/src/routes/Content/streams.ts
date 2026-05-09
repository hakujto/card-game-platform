import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

router.get('/', async (_req, res) => {
  const items = await prisma.stream.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.streamUrl !== undefined) data.streamUrl = body.streamUrl;
    if (body.platform !== undefined) data.platform = body.platform;
    if (body.status !== undefined) data.status = body.status;
    if (body.viewerCountPeak !== undefined) data.viewerCountPeak = body.viewerCountPeak;
    if (body.scheduledStart !== undefined) data.scheduledStart = new Date(body.scheduledStart);
    if (body.actualStart !== undefined) data.actualStart = new Date(body.actualStart);
    if (body.endedAt !== undefined) data.endedAt = new Date(body.endedAt);
    if (body.vodUrl !== undefined) data.vodUrl = body.vodUrl;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.streamerId !== undefined) data.streamerId = body.streamerId;
  try {
    const entity = await prisma.stream.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.stream.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.streamUrl !== undefined) data.streamUrl = body.streamUrl;
    if (body.platform !== undefined) data.platform = body.platform;
    if (body.status !== undefined) data.status = body.status;
    if (body.viewerCountPeak !== undefined) data.viewerCountPeak = body.viewerCountPeak;
    if (body.scheduledStart !== undefined) data.scheduledStart = new Date(body.scheduledStart);
    if (body.actualStart !== undefined) data.actualStart = new Date(body.actualStart);
    if (body.endedAt !== undefined) data.endedAt = new Date(body.endedAt);
    if (body.vodUrl !== undefined) data.vodUrl = body.vodUrl;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.streamerId !== undefined) data.streamerId = body.streamerId;
  try {
    const entity = await prisma.stream.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.streamUrl !== undefined) data.streamUrl = body.streamUrl;
    if (body.platform !== undefined) data.platform = body.platform;
    if (body.status !== undefined) data.status = body.status;
    if (body.viewerCountPeak !== undefined) data.viewerCountPeak = body.viewerCountPeak;
    if (body.scheduledStart !== undefined) data.scheduledStart = new Date(body.scheduledStart);
    if (body.actualStart !== undefined) data.actualStart = new Date(body.actualStart);
    if (body.endedAt !== undefined) data.endedAt = new Date(body.endedAt);
    if (body.vodUrl !== undefined) data.vodUrl = body.vodUrl;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.streamerId !== undefined) data.streamerId = body.streamerId;
  try {
    const entity = await prisma.stream.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.stream.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
