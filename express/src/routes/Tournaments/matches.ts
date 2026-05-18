import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { MatchService } from '../../services/Tournaments/match_service.js';

const router = Router();
const service = new MatchService();

function validate(data: any): void {
  if (!(((data.player1Wins == null || data.player1Wins >= 0) && (data.player2Wins == null || data.player2Wins >= 0)))) throw new Error(`Win counts must not be negative`);
  if (!(((data.player1Wins == null || (data.player1Wins >= 0 && data.player1Wins <= 2)) && (data.player2Wins == null || (data.player2Wins >= 0 && data.player2Wins <= 2))))) throw new Error(`Win counts cannot exceed 2 in a best-of-3 match`);
  if ((data.status === 'BYE') && !(data.player2Id == null)) throw new Error(`BYE match must not have a second player`);
  if ((data.endedAt != null) && !((data.endedAt == null || (data.startedAt != null && data.endedAt > data.startedAt)))) throw new Error(`Match end time must be after start time`);
  if ((data.status === 'COMPLETED') && !((data.startedAt === undefined || data.startedAt != null))) throw new Error(`Completed match must have a start time`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.match.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.tableNumber !== undefined) data.tableNumber = body.tableNumber;
    if (body.status !== undefined) data.status = body.status;
    if (body.player1Wins !== undefined) data.player1Wins = body.player1Wins;
    if (body.player2Wins !== undefined) data.player2Wins = body.player2Wins;
    if (body.startedAt !== undefined) data.startedAt = body.startedAt != null ? new Date(body.startedAt) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.resultNotes !== undefined) data.resultNotes = body.resultNotes;
    if (body.roundId !== undefined) data.roundId = body.roundId;
    if (body.player1Id !== undefined) data.player1Id = body.player1Id;
    if (body.player2Id !== undefined) data.player2Id = body.player2Id;
  try {
  validate(data);
    const entity = await prisma.match.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.match.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.tableNumber !== undefined) data.tableNumber = body.tableNumber;
    if (body.status !== undefined) data.status = body.status;
    if (body.player1Wins !== undefined) data.player1Wins = body.player1Wins;
    if (body.player2Wins !== undefined) data.player2Wins = body.player2Wins;
    if (body.startedAt !== undefined) data.startedAt = body.startedAt != null ? new Date(body.startedAt) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.resultNotes !== undefined) data.resultNotes = body.resultNotes;
    if (body.roundId !== undefined) data.roundId = body.roundId;
    if (body.player1Id !== undefined) data.player1Id = body.player1Id;
    if (body.player2Id !== undefined) data.player2Id = body.player2Id;
  try {
  validate(data);
    const entity = await prisma.match.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.tableNumber !== undefined) data.tableNumber = body.tableNumber;
    if (body.status !== undefined) data.status = body.status;
    if (body.player1Wins !== undefined) data.player1Wins = body.player1Wins;
    if (body.player2Wins !== undefined) data.player2Wins = body.player2Wins;
    if (body.startedAt !== undefined) data.startedAt = body.startedAt != null ? new Date(body.startedAt) : null;
    if (body.endedAt !== undefined) data.endedAt = body.endedAt != null ? new Date(body.endedAt) : null;
    if (body.resultNotes !== undefined) data.resultNotes = body.resultNotes;
    if (body.roundId !== undefined) data.roundId = body.roundId;
    if (body.player1Id !== undefined) data.player1Id = body.player1Id;
    if (body.player2Id !== undefined) data.player2Id = body.player2Id;
  try {
  validate(data);
    const entity = await prisma.match.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.match.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/record', async (req, res) => {
  const id = Number((req.params as any).id);
  const p1Wins = req.body.p1Wins;
  const p2Wins = req.body.p2Wins;
  try {
    await service.record_result(id, p1Wins, p2Wins);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/winner', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.determine_winner(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/concede', async (req, res) => {
  const id = Number((req.params as any).id);
  const playerId = req.body.playerId;
  try {
    await service.concede(id, playerId);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/draw', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.draw(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
