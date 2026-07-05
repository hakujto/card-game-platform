import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { CardService } from '../../services/Cards/card_service.js';

const router = Router();
const service = new CardService();

function validate(data: any): void {
  if (data.manaCost != null && Number(data.manaCost) < 0) throw new Error('mana_cost: must be >= 0');
  if (data.manaCost != null && Number(data.manaCost) > 20) throw new Error('mana_cost: must be <= 20');
  if (data.powerLevel != null && Number(data.powerLevel) < 1) throw new Error('power_level: must be >= 1');
  if (data.powerLevel != null && Number(data.powerLevel) > 10) throw new Error('power_level: must be <= 10');
  if ((data.cardType === 'Creature') && data.attack == null) throw new Error('attack is required');
  if ((data.cardType === 'Creature') && data.defense == null) throw new Error('defense is required');
  if ((data.cardType === 'Planeswalker') && data.loyalty == null) throw new Error('loyalty is required');
  if (!((data.manaCost == null || (data.manaCost >= 0 && data.manaCost <= 20)))) throw new Error(`mana_cost must be between 0 and 20`);
  if (!((data.powerLevel == null || (data.powerLevel >= 1 && data.powerLevel <= 10)))) throw new Error(`power_level must be between 1 and 10`);
  if (!(!((data.isBanned === true && data.isRestricted === true)))) throw new Error(`Card cannot be both banned and restricted at the same time`);
  if ((data.cardType === 'CREATURE') && !((data.attack === undefined || data.attack != null) && (data.defense === undefined || data.defense != null))) throw new Error(`Creature card must have attack and defense`);
  if ((data.cardType === 'PLANESWALKER') && !((data.loyalty === undefined || data.loyalty != null))) throw new Error(`Planeswalker card must have loyalty`);
  if ((data.cardType === 'LAND') && !(data.manaCost === 0)) throw new Error(`Land card must have zero mana cost`);
  if ((data.cardType !== 'PLANESWALKER') && !(data.loyalty == null)) throw new Error(`Only Planeswalker cards can have loyalty`);
  if ((data.isBanned === true) && !(data.legalFormats === "message")) throw new Error(`banned_card_not_in_legal_formats`);
}

router.get('/', async (req, res) => {
  const q = req.query.q as string | undefined;
  const where = q ? { OR: [{ name: { contains: q } }, { artistName: { contains: q } }] } : undefined;
  const items = await prisma.card.findMany(where ? { where } : undefined);
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.publicId !== undefined) data.publicId = body.publicId;
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
    if (body.metadata !== undefined) data.metadata = body.metadata;
    if (body.totalCopiesInCirculation !== undefined) data.totalCopiesInCirculation = body.totalCopiesInCirculation;
    if (body.setId !== undefined) data.setId = body.setId;
  try {
  validate(data);
    const entity = await prisma.card.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Validation error') });
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
    if (body.publicId !== undefined) data.publicId = body.publicId;
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
    if (body.powerLevel !== undefined) data.powerLevel = body.powerLevel;
    if (body.metadata !== undefined) data.metadata = body.metadata;
    if (body.totalCopiesInCirculation !== undefined) data.totalCopiesInCirculation = body.totalCopiesInCirculation;
    if (body.setId !== undefined) data.setId = body.setId;
  try {
  validate(data);
    const existing = await prisma.card.findUnique({ where: { id: Number(req.params.id) } });
    if (!existing) return res.status(404).json({ error: 'Not found' });
    const entity = await prisma.card.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.publicId !== undefined) data.publicId = body.publicId;
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
    if (body.powerLevel !== undefined) data.powerLevel = body.powerLevel;
    if (body.metadata !== undefined) data.metadata = body.metadata;
    if (body.totalCopiesInCirculation !== undefined) data.totalCopiesInCirculation = body.totalCopiesInCirculation;
    if (body.setId !== undefined) data.setId = body.setId;
  try {
  validate(data);
    const existing = await prisma.card.findUnique({ where: { id: Number(req.params.id) } });
    if (!existing) return res.status(404).json({ error: 'Not found' });
    const entity = await prisma.card.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : err?.code === 'P2002' ? 422 : 400;
    res.status(status).json({ error: err?.code === 'P2002' ? 'Value must be unique' : (err?.message ?? 'Error') });
  }
});

router.post('/:id/ban', async (req, res) => {
  const userRole = (req as any).user?.role;
  if (!['admin', 'moderator'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for ban' }); return; }
  const id = Number((req.params as any).id);
  try {
    await service.ban(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/unban', async (req, res) => {
  const userRole = (req as any).user?.role;
  if (!['admin', 'moderator'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for unban' }); return; }
  const id = Number((req.params as any).id);
  try {
    await service.unban(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/restrict', async (req, res) => {
  const userRole = (req as any).user?.role;
  if (!['admin', 'moderator'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for restrict' }); return; }
  const id = Number((req.params as any).id);
  try {
    await service.restrict(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/unrestrict', async (req, res) => {
  const userRole = (req as any).user?.role;
  if (!['admin', 'moderator'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for unrestrict' }); return; }
  const id = Number((req.params as any).id);
  try {
    await service.unrestrict(id);
    res.status(204).send();
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.put('/:id', async (req, res) => {
  const userRole = (req as any).user?.role;
  if (!['admin'].includes(userRole)) { res.status(403).json({ error: 'Insufficient role for replace' }); return; }
  const id = Number((req.params as any).id);
  const data = req.body.data;
  try {
    const result = await service.replace(id, data);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/value', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.calculate_value(id);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/rarity-bonus', async (req, res) => {
  const id = Number((req.params as any).id);
  const multiplier = req.body.multiplier;
  try {
    const result = await service.apply_rarity_bonus(id, multiplier);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/legal', async (req, res) => {
  const id = Number((req.params as any).id);
  const format = (req.query as any).format;
  try {
    const result = await service.is_legal_in_format(id, format);
    res.json({ result });
  } catch (err: any) {
    const status = err?.message?.startsWith('Guard') ? 422 : 404;
    res.status(status).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
