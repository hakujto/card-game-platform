import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { PlayerSeasonStatsService } from '../../services/Players/player_season_stats_service.js';

const router = Router();
const service = new PlayerSeasonStatsService();

function validate(data: any): void {
  if (!((data.wins == null || data.wins >= 0))) throw new Error(`Season wins must not be negative`);
  if (!((data.losses == null || data.losses >= 0))) throw new Error(`Season losses must not be negative`);
  if (!((data.tournamentWins == null || data.tournamentWins >= 0))) throw new Error(`Season tournament wins must not be negative`);
  if (!((data.seasonPoints == null || data.seasonPoints >= 0))) throw new Error(`Season points must not be negative`);
}

router.get('/', async (req, res) => {
  const items = await prisma.playerSeasonStats.findMany();
  res.json(items);
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.playerSeasonStats.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.get('/:id/win-rate', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.win_rate(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/points', async (req, res) => {
  const id = Number((req.params as any).id);
  const points = req.body.points;
  try {
    await service.add_points(id, points);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/tournament-win', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.record_tournament_win(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
