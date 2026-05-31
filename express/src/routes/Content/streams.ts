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
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('scheduledStart' in r) { r.scheduledStart = r.scheduledStart; delete r.scheduledStart; }
  if ('actualStart' in r) { r.actualStart = r.actualStart; delete r.actualStart; }
  if ('endedAt' in r) { r.endedAt = r.endedAt; delete r.endedAt; }
  return r;
}

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  'Scheduled': ['Live'],
  'Live': ['Ended']
};

function assertTransition(current: string, to: string): void {
  const allowed = ALLOWED_TRANSITIONS[current] ?? [];
  if (!allowed.includes(to)) throw new Error(`Transition ${current} -> ${to} is not allowed`);
}

class StreamLifecycleService {

  async transitionScheduledToLive(id: number): Promise<any> {
    const entity = await prisma.stream.findUnique({ where: { id } });
    if (!entity) throw new Error('Stream not found: ' + id);
    assertTransition((entity as any).status, 'Live');
    if ((entity as any).streamUrl == null) throw new Error('stream_url is required for Scheduled -> Live');
    const updated = await prisma.stream.update({ where: { id }, data: { status: 'LIVE' as any } });
    // TODO: entity.goLive(); // @after
    return updated;
  }

  async transitionLiveToEnded(id: number): Promise<any> {
    const entity = await prisma.stream.findUnique({ where: { id } });
    if (!entity) throw new Error('Stream not found: ' + id);
    assertTransition((entity as any).status, 'Ended');
    const updated = await prisma.stream.update({ where: { id }, data: { status: 'ENDED' as any } });
    // TODO: entity.end(); // @after
    return updated;
  }

  async transitionEndedToLive(id: number): Promise<any> {
    const entity = await prisma.stream.findUnique({ where: { id } });
    if (!entity) throw new Error('Stream not found: ' + id);
    throw new Error('Transition Ended -> Live is not allowed');
  }
}
const lifecycleService = new StreamLifecycleService();


router.get('/', async (req, res) => {
  const q = req.query.q as string | undefined;
  const where = q ? { OR: [{ title: { contains: q } }] } : undefined;
  const items = await prisma.stream.findMany(where ? { where } : undefined);
  res.json(items.map(applyProjection));
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.streamUrl !== undefined) data.streamUrl = body.streamUrl;
    if (body.status !== undefined) data.status = body.status;
    if (body.platform !== undefined) data.platform = body.platform;
    if (body.language !== undefined) data.language = body.language;
    if (body.isOfficial !== undefined) data.isOfficial = body.isOfficial;
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
    res.status(201).json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.stream.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(applyProjection(entity));
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.streamUrl !== undefined) data.streamUrl = body.streamUrl;
    if (body.status !== undefined) data.status = body.status;
    if (body.platform !== undefined) data.platform = body.platform;
    if (body.language !== undefined) data.language = body.language;
    if (body.isOfficial !== undefined) data.isOfficial = body.isOfficial;
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
    res.json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.title !== undefined) data.title = body.title;
    if (body.streamUrl !== undefined) data.streamUrl = body.streamUrl;
    if (body.status !== undefined) data.status = body.status;
    if (body.platform !== undefined) data.platform = body.platform;
    if (body.language !== undefined) data.language = body.language;
    if (body.isOfficial !== undefined) data.isOfficial = body.isOfficial;
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
    res.json(applyProjection(entity));
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
  }
});

router.post('/:id/live', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.go_live(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/end', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.end(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/viewers', async (req, res) => {
  const id = Number((req.params as any).id);
  const count = req.body.count;
  try {
    await service.update_viewer_peak(id, count);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/duration', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.duration_minutes(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/transitions/scheduled-to-live', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionScheduledToLive(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/live-to-ended', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionLiveToEnded(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id/transitions/ended-to-live', async (req, res) => {
  const id = Number(req.params.id);
  try {
    const entity = await lifecycleService.transitionEndedToLive(id);
    res.json(entity);
  } catch (err: any) {
    const status = err?.message?.includes('not allowed') || err?.message?.includes('is not allowed') ? 409
      : err?.message?.includes('required') || err?.message?.includes('must be') ? 422
      : 404;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});
export default router;
