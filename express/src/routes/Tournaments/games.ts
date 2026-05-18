import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { GameService } from '../../services/Tournaments/game_service.js';

const router = Router();
const service = new GameService();

function validate(data: any): void {
  if (!((data.gameNumber == null || (data.gameNumber >= 1 && data.gameNumber <= 3)))) throw new Error(`Game number must be between 1 and 3 (best-of-3)`);
  if ((data.turnsPlayed != null) && !((data.turnsPlayed == null || data.turnsPlayed > 0))) throw new Error(`Turns played must be greater than zero`);
  if ((data.durationSeconds != null) && !((data.durationSeconds == null || data.durationSeconds > 0))) throw new Error(`Game duration must be greater than zero`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.game.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.gameNumber !== undefined) data.gameNumber = body.gameNumber;
    if (body.winnerSide !== undefined) data.winnerSide = body.winnerSide;
    if (body.turnsPlayed !== undefined) data.turnsPlayed = body.turnsPlayed;
    if (body.durationSeconds !== undefined) data.durationSeconds = body.durationSeconds;
    if (body.endedBy !== undefined) data.endedBy = body.endedBy;
    if (body.replayUrl !== undefined) data.replayUrl = body.replayUrl;
    if (body.matchId !== undefined) data.matchId = body.matchId;
    if (body.winnerId !== undefined) data.winnerId = body.winnerId;
  try {
  validate(data);
    const entity = await prisma.game.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.game.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.gameNumber !== undefined) data.gameNumber = body.gameNumber;
    if (body.winnerSide !== undefined) data.winnerSide = body.winnerSide;
    if (body.turnsPlayed !== undefined) data.turnsPlayed = body.turnsPlayed;
    if (body.durationSeconds !== undefined) data.durationSeconds = body.durationSeconds;
    if (body.endedBy !== undefined) data.endedBy = body.endedBy;
    if (body.replayUrl !== undefined) data.replayUrl = body.replayUrl;
    if (body.matchId !== undefined) data.matchId = body.matchId;
    if (body.winnerId !== undefined) data.winnerId = body.winnerId;
  try {
  validate(data);
    const entity = await prisma.game.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.gameNumber !== undefined) data.gameNumber = body.gameNumber;
    if (body.winnerSide !== undefined) data.winnerSide = body.winnerSide;
    if (body.turnsPlayed !== undefined) data.turnsPlayed = body.turnsPlayed;
    if (body.durationSeconds !== undefined) data.durationSeconds = body.durationSeconds;
    if (body.endedBy !== undefined) data.endedBy = body.endedBy;
    if (body.replayUrl !== undefined) data.replayUrl = body.replayUrl;
    if (body.matchId !== undefined) data.matchId = body.matchId;
    if (body.winnerId !== undefined) data.winnerId = body.winnerId;
  try {
  validate(data);
    const entity = await prisma.game.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.game.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/winner', async (req, res) => {
  const id = Number((req.params as any).id);
  const winnerSide = req.body.winnerSide;
  try {
    await service.record_winner(id, winnerSide);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
