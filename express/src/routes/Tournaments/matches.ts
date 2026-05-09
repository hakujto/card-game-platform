import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

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
    if (body.startedAt !== undefined) data.startedAt = new Date(body.startedAt);
    if (body.endedAt !== undefined) data.endedAt = new Date(body.endedAt);
    if (body.resultNotes !== undefined) data.resultNotes = body.resultNotes;
    if (body.roundId !== undefined) data.roundId = body.roundId;
    if (body.player1Id !== undefined) data.player1Id = body.player1Id;
    if (body.player2Id !== undefined) data.player2Id = body.player2Id;
    if (body.gamesId !== undefined) data.gamesId = body.gamesId;
  try {
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
    if (body.startedAt !== undefined) data.startedAt = new Date(body.startedAt);
    if (body.endedAt !== undefined) data.endedAt = new Date(body.endedAt);
    if (body.resultNotes !== undefined) data.resultNotes = body.resultNotes;
    if (body.roundId !== undefined) data.roundId = body.roundId;
    if (body.player1Id !== undefined) data.player1Id = body.player1Id;
    if (body.player2Id !== undefined) data.player2Id = body.player2Id;
    if (body.gamesId !== undefined) data.gamesId = body.gamesId;
  try {
    const entity = await prisma.match.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.tableNumber !== undefined) data.tableNumber = body.tableNumber;
    if (body.status !== undefined) data.status = body.status;
    if (body.player1Wins !== undefined) data.player1Wins = body.player1Wins;
    if (body.player2Wins !== undefined) data.player2Wins = body.player2Wins;
    if (body.startedAt !== undefined) data.startedAt = new Date(body.startedAt);
    if (body.endedAt !== undefined) data.endedAt = new Date(body.endedAt);
    if (body.resultNotes !== undefined) data.resultNotes = body.resultNotes;
    if (body.roundId !== undefined) data.roundId = body.roundId;
    if (body.player1Id !== undefined) data.player1Id = body.player1Id;
    if (body.player2Id !== undefined) data.player2Id = body.player2Id;
    if (body.gamesId !== undefined) data.gamesId = body.gamesId;
  try {
    const entity = await prisma.match.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
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

export default router;
