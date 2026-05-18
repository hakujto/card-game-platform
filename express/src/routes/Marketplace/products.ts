import { Router } from 'express';
import { prisma } from '../../lib/prisma.js';
import { ProductService } from '../../services/Marketplace/product_service.js';

const router = Router();
const service = new ProductService();

function validate(data: any): void {
  if (!((data.price == null || Number(data.price) > 0))) throw new Error(`Product price must be greater than zero`);
  if (!((data.stock == null || data.stock >= 0))) throw new Error(`Product stock must not be negative`);
  if (!((data.discountPercent == null || (data.discountPercent >= 0 && data.discountPercent <= 100)))) throw new Error(`Product discount percent must be between 0 and 100`);
}

router.get('/', async (_req, res) => {
  const items = await prisma.product.findMany();
  res.json(items);
});

router.post('/', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.productType !== undefined) data.productType = body.productType;
    if (body.price !== undefined) data.price = body.price;
    if (body.stock !== undefined) data.stock = body.stock;
    if (body.active !== undefined) data.active = body.active;
    if (body.discountPercent !== undefined) data.discountPercent = body.discountPercent;
    if (body.description !== undefined) data.description = body.description;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.featured !== undefined) data.featured = body.featured;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
  try {
  validate(data);
    const entity = await prisma.product.create({ data });
    res.status(201).json(entity);
  } catch (err: any) {
    res.status(400).json({ error: err?.message ?? 'Validation error' });
  }
});

router.get('/:id', async (req, res) => {
  const entity = await prisma.product.findUnique({ where: { id: Number(req.params.id) } });
  if (!entity) return res.status(404).json({ error: 'Not found' });
  res.json(entity);
});

router.put('/:id', async (req, res) => {
  const body = req.body;
  const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.productType !== undefined) data.productType = body.productType;
    if (body.price !== undefined) data.price = body.price;
    if (body.stock !== undefined) data.stock = body.stock;
    if (body.active !== undefined) data.active = body.active;
    if (body.discountPercent !== undefined) data.discountPercent = body.discountPercent;
    if (body.description !== undefined) data.description = body.description;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.featured !== undefined) data.featured = body.featured;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
  try {
  validate(data);
    const entity = await prisma.product.update({ where: { id: Number(req.params.id) }, data });
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
    if (body.productType !== undefined) data.productType = body.productType;
    if (body.price !== undefined) data.price = body.price;
    if (body.stock !== undefined) data.stock = body.stock;
    if (body.active !== undefined) data.active = body.active;
    if (body.discountPercent !== undefined) data.discountPercent = body.discountPercent;
    if (body.description !== undefined) data.description = body.description;
    if (body.imageUrl !== undefined) data.imageUrl = body.imageUrl;
    if (body.featured !== undefined) data.featured = body.featured;
    if (body.cardId !== undefined) data.cardId = body.cardId;
    if (body.cardSetId !== undefined) data.cardSetId = body.cardSetId;
  try {
  validate(data);
    const entity = await prisma.product.update({ where: { id: Number(req.params.id) }, data });
    res.json(entity);
  } catch (err: any) {
    const status = err?.code === 'P2025' ? 404 : 400;
    res.status(status).json({ error: err?.message ?? 'Error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await prisma.product.delete({ where: { id: Number(req.params.id) } });
    res.status(204).send();
  } catch {
    res.status(404).json({ error: 'Not found' });
  }
});

router.post('/:id/activate', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.activate(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/deactivate', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    await service.deactivate(id);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.patch('/:id/discount', async (req, res) => {
  const id = Number((req.params as any).id);
  const percent = req.body.percent;
  try {
    const result = await service.apply_discount(id, percent);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.post('/:id/restock', async (req, res) => {
  const id = Number((req.params as any).id);
  const quantity = req.body.quantity;
  try {
    await service.restock(id, quantity);
    res.status(204).send();
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/effective-price', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.effective_price(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});

router.get('/:id/in-stock', async (req, res) => {
  const id = Number((req.params as any).id);
  try {
    const result = await service.is_in_stock(id);
    res.json({ result });
  } catch (err: any) {
    res.status(404).json({ error: err?.message ?? 'Not found' });
  }
});
export default router;
