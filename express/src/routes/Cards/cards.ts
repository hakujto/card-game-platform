import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

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
    if (body.rulingsId !== undefined) data.rulingsId = body.rulingsId;
    if (body.abilitiesId !== undefined) data.abilitiesId = body.abilitiesId;
  try {
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
    if (body.rulingsId !== undefined) data.rulingsId = body.rulingsId;
    if (body.abilitiesId !== undefined) data.abilitiesId = body.abilitiesId;
  try {
    const entity = await prisma.card.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
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
    if (body.rulingsId !== undefined) data.rulingsId = body.rulingsId;
    if (body.abilitiesId !== undefined) data.abilitiesId = body.abilitiesId;
  try {
    const entity = await prisma.card.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch {
    res.status(404).json({ error: 'Not found' });
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

export default router;
