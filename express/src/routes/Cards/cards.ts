import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { CardService } from '../../services/Cards/card_service.js';

const router = Router();
const service = new CardService();

function validate(data: any): void {
  if (!((data.manaCost == null || (data.manaCost >= 0 && data.manaCost <= 20)))) throw new Error(`mana_cost must be between 0 and 20`);
  if (!((data.powerLevel == null || (data.powerLevel >= 1 && data.powerLevel <= 10)))) throw new Error(`power_level must be between 1 and 10`);
  if (!(!((data.isBanned === true && data.isRestricted === true)))) throw new Error(`Card cannot be both banned and restricted at the same time`);
  if ((data.cardType === 'CREATURE') && !((data.attack === undefined || data.attack != null) && (data.defense === undefined || data.defense != null))) throw new Error(`Creature card must have attack and defense`);
  if ((data.cardType === 'PLANESWALKER') && !((data.loyalty === undefined || data.loyalty != null))) throw new Error(`Planeswalker card must have loyalty`);
  if ((data.cardType !== 'PLANESWALKER') && !(data.loyalty == null)) throw new Error(`Only Planeswalker cards can have loyalty`);
  if ((data.isBanned === true) && !(data.legalFormats === "message")) throw new Error(`banned_card_not_in_legal_formats`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.card.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.cardType !== undefined) data.cardType = body.cardType;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.manaCost !== undefined) data.manaCost = body.manaCost;
    if (body.manaColors !== undefined) data.manaColors = body.manaColors;
    if (body.attack !== undefined) data.attack = body.attack;
    if (body.defense !== undefined) data.defense = body.defense;
    if (body.loyalty !== undefined) data.loyalty = body.loyalty;
    if (body.description !== undefined) data.description = body.description;
    if (body.flavorText !== undefined) data.flavorText = body.flavorText;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.artistName !== undefined) data.artistName = body.artistName;
    if (body.legalFormats !== undefined) data.legalFormats = body.legalFormats;
    if (body.isBanned !== undefined) data.isBanned = body.isBanned;
    if (body.isRestricted !== undefined) data.isRestricted = body.isRestricted;
    if (body.powerLevel !== undefined) data.powerLevel = body.powerLevel;
    if (body.setId !== undefined) data.setId = body.setId;
  try {
  validate(data);
    const entity = await prisma.card.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.card.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.cardType !== undefined) data.cardType = body.cardType;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.manaCost !== undefined) data.manaCost = body.manaCost;
    if (body.manaColors !== undefined) data.manaColors = body.manaColors;
    if (body.attack !== undefined) data.attack = body.attack;
    if (body.defense !== undefined) data.defense = body.defense;
    if (body.loyalty !== undefined) data.loyalty = body.loyalty;
    if (body.description !== undefined) data.description = body.description;
    if (body.flavorText !== undefined) data.flavorText = body.flavorText;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.artistName !== undefined) data.artistName = body.artistName;
    if (body.legalFormats !== undefined) data.legalFormats = body.legalFormats;
    if (body.isBanned !== undefined) data.isBanned = body.isBanned;
    if (body.isRestricted !== undefined) data.isRestricted = body.isRestricted;
    if (body.powerLevel !== undefined) data.powerLevel = body.powerLevel;
    if (body.setId !== undefined) data.setId = body.setId;
  try {
  validate(data);
    const entity = await prisma.card.update({ where: { id: Number(req.params.id) }, data });
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
    if (body.cardType !== undefined) data.cardType = body.cardType;
    if (body.rarity !== undefined) data.rarity = body.rarity;
    if (body.manaCost !== undefined) data.manaCost = body.manaCost;
    if (body.manaColors !== undefined) data.manaColors = body.manaColors;
    if (body.attack !== undefined) data.attack = body.attack;
    if (body.defense !== undefined) data.defense = body.defense;
    if (body.loyalty !== undefined) data.loyalty = body.loyalty;
    if (body.description !== undefined) data.description = body.description;
    if (body.flavorText !== undefined) data.flavorText = body.flavorText;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.artistName !== undefined) data.artistName = body.artistName;
    if (body.legalFormats !== undefined) data.legalFormats = body.legalFormats;
    if (body.isBanned !== undefined) data.isBanned = body.isBanned;
    if (body.isRestricted !== undefined) data.isRestricted = body.isRestricted;
    if (body.powerLevel !== undefined) data.powerLevel = body.powerLevel;
    if (body.setId !== undefined) data.setId = body.setId;
  try {
  validate(data);
    const entity = await prisma.card.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.card.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/ban', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.ban(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/unban', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.unban(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/restrict', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.restrict(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/unrestrict', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.unrestrict(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/value', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.calculate_value(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/rarity-bonus', async (req, res) => {
  const id = Number((req.params as any).id);
  const multiplier = req.body.multiplier;
  try {
    const result = await service.apply_rarity_bonus(id, multiplier);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/legal', async (req, res) => {
  const id = Number((req.params as any).id);
  const format = (req.query as any).format;
  try {
    const result = await service.is_legal_in_format(id, format);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
