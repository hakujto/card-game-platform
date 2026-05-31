import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { CardPriceHistoryService } from '../../services/Marketplace/card_price_history_service.js';

const router = Router();
const service = new CardPriceHistoryService();

function validate(data: any): void {
  if (!(((data.minPrice == null || (data.avgPrice != null && Number(data.minPrice) <= Number(data.avgPrice))) && (data.avgPrice == null || (data.maxPrice != null && Number(data.avgPrice) <= Number(data.maxPrice)))))) throw new Error(`min_price <= avg_price <= max_price must hold`);
  if (!((data.volume == null || data.volume >= 0))) throw new Error(`Price history volume must not be negative`);
  if (!((data.minPrice == null || Number(data.minPrice) >= 0))) throw new Error(`Prices must not be negative`);
}

router.get('/', async (req, res) => {
  const items = await prisma.cardPriceHistory.findMany();
  res.json(items);
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.cardPriceHistory.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.get('/:id/change', async (req, res) => {
  const id = Number((req.params as any).id);
  const previousAvg = (req.query as any).previousAvg;
  try {
    const result = await service.price_change_percent(id, previousAvg);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/spike', async (req, res) => {
  const id = Number((req.params as any).id);
  const thresholdPercent = (req.query as any).thresholdPercent;
  try {
    const result = await service.is_price_spike(id, thresholdPercent);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
