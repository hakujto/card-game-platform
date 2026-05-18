import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { DeckService } from '../../services/Cards/deck_service.js';

const router = Router();
const service = new DeckService();

function validate(data: any): void {
  if (!((data.wins == null || data.wins >= 0))) throw new Error(`Deck wins count must not be negative`);
  if (!((data.losses == null || data.losses >= 0))) throw new Error(`Deck losses count must not be negative`);
  if (!((data.draws == null || data.draws >= 0))) throw new Error(`Deck draws count must not be negative`);
  if ((data.isTournamentLegal === true) && !(data.isPublic === true)) throw new Error(`Tournament-legal deck must be made public`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.deck.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.isPublic !== undefined) data.isPublic = body.isPublic;
    if (body.isTournamentLegal !== undefined) data.isTournamentLegal = body.isTournamentLegal;
    if (body.archetype !== undefined) data.archetype = body.archetype;
    if (body.wins !== undefined) data.wins = body.wins;
    if (body.losses !== undefined) data.losses = body.losses;
    if (body.draws !== undefined) data.draws = body.draws;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
  validate(data);
    const entity = await prisma.deck.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.deck.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.isPublic !== undefined) data.isPublic = body.isPublic;
    if (body.isTournamentLegal !== undefined) data.isTournamentLegal = body.isTournamentLegal;
    if (body.archetype !== undefined) data.archetype = body.archetype;
    if (body.wins !== undefined) data.wins = body.wins;
    if (body.losses !== undefined) data.losses = body.losses;
    if (body.draws !== undefined) data.draws = body.draws;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
  validate(data);
    const entity = await prisma.deck.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.description !== undefined) data.description = body.description;
    if (body.format !== undefined) data.format = body.format;
    if (body.isPublic !== undefined) data.isPublic = body.isPublic;
    if (body.isTournamentLegal !== undefined) data.isTournamentLegal = body.isTournamentLegal;
    if (body.archetype !== undefined) data.archetype = body.archetype;
    if (body.wins !== undefined) data.wins = body.wins;
    if (body.losses !== undefined) data.losses = body.losses;
    if (body.draws !== undefined) data.draws = body.draws;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.updatedAt !== undefined) data.updatedAt = body.updatedAt != null ? new Date(body.updatedAt) : null;
    if (body.playerId !== undefined) data.playerId = body.playerId;
  try {
  validate(data);
    const entity = await prisma.deck.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.deck.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.get('/:id/validate', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.validate_size(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/cards', async (req, res) => {
  const id = Number((req.params as any).id);
  const cardId = req.body.cardId;
  const quantity = req.body.quantity;
  try {
    await service.add_card(id, cardId, quantity);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.delete('/:id/cards/:card_id', async (req, res) => {
  const id = Number((req.params as any).id);
  const cardId = (req.params as any).card_id;
  try {
    await service.remove_card(id, cardId);
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

router.post('/:id/clone', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.clone(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/publish', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.publish(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/unpublish', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.unpublish(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/certify', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.certify_tournament_legal(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
