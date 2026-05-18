import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { StreamService } from '../../services/Content/stream_service.js';

const router = Router();
const service = new StreamService();

function validate(data: any): void {
  if (!((data.viewerCountPeak == null || data.viewerCountPeak >= 0))) throw new Error(`Peak viewer count must not be negative`);
  if ((data.actualStart != null) && !(data.status === 'LIVE')) throw new Error(`actual_start_requires_live_or_ended`);
  if ((data.endedAt != null) && !(data.status === 'ENDED')) throw new Error(`ended_at can only be set when stream status is Ended`);
}

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
    if (body.scheduledStart !== undefined) data.scheduledStart = body.scheduledStart != null ? new Date(body.scheduledStart) : null;
    if (body.actualStart !== undefined) data.actualStart = body.actualStart != null ? new Date(body.actualStart) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.vodUrl !== undefined) data.vodUrl = body.vodUrl;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.streamerId !== undefined) data.streamerId = body.streamerId;
  try {
  validate(data);
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
    if (body.scheduledStart !== undefined) data.scheduledStart = body.scheduledStart != null ? new Date(body.scheduledStart) : null;
    if (body.actualStart !== undefined) data.actualStart = body.actualStart != null ? new Date(body.actualStart) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.vodUrl !== undefined) data.vodUrl = body.vodUrl;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.streamerId !== undefined) data.streamerId = body.streamerId;
  try {
  validate(data);
    const entity = await prisma.stream.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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
    if (body.scheduledStart !== undefined) data.scheduledStart = body.scheduledStart != null ? new Date(body.scheduledStart) : null;
    if (body.actualStart !== undefined) data.actualStart = body.actualStart != null ? new Date(body.actualStart) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.vodUrl !== undefined) data.vodUrl = body.vodUrl;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.streamerId !== undefined) data.streamerId = body.streamerId;
  try {
  validate(data);
    const entity = await prisma.stream.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
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

router.post('/:id/live', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.go_live(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/end', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.end(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/viewers', async (req, res) => {
  const id = Number((req.params as any).id);
  const count = req.body.count;
  try {
    await service.update_viewer_peak(id, count);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/duration', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.duration_minutes(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
