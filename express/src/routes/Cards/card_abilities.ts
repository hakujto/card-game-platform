import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';

const router = Router();

function validate(data: any): void {
  if ((data.abilityType === 'KEYWORD') && !((data.keyword === undefined || data.keyword != null))) throw new Error(`Keyword ability must have a keyword name`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.cardAbility.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.abilityType !== undefined) data.abilityType = body.abilityType;
    if (body.keyword !== undefined) data.keyword = body.keyword;
    if (body.abilityText !== undefined) data.abilityText = body.abilityText;
    if (body.timing !== undefined) data.timing = body.timing;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.cardAbility.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.cardAbility.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.abilityType !== undefined) data.abilityType = body.abilityType;
    if (body.keyword !== undefined) data.keyword = body.keyword;
    if (body.abilityText !== undefined) data.abilityText = body.abilityText;
    if (body.timing !== undefined) data.timing = body.timing;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.cardAbility.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.patch('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.abilityType !== undefined) data.abilityType = body.abilityType;
    if (body.keyword !== undefined) data.keyword = body.keyword;
    if (body.abilityText !== undefined) data.abilityText = body.abilityText;
    if (body.timing !== undefined) data.timing = body.timing;
    if (body.cardId !== undefined) data.cardId = body.cardId;
  try {
  validate(data);
    const entity = await prisma.cardAbility.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.cardAbility.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

export default router;
