import { BadRequestException, Body, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CardService } from './card.service';


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
  if ((data.isBanned === true) && !((!Array.isArray(data.legalFormats) || data.legalFormats.length === 0))) throw new Error(`Banned card must not appear in any legal formats`);
}

@Controller('cards')
export class CardController {
  constructor(private readonly prisma: PrismaService, private readonly cardService: CardService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ name: { contains: q } }, { artistName: { contains: q } }] } : undefined;
    const items = await this.prisma.card.findMany(where ? { where } : undefined);
    return items;
  }

  @Post()
  async create(@Body() body: any) {
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
      const entity = await this.prisma.card.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.card.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
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
      const existing = await this.prisma.card.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.card.update({ where: { id: Number(id) }, data });
      return entity;
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() body: any) {
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
      const existing = await this.prisma.card.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.card.update({ where: { id: Number(id) }, data });
      return entity;
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Post('/:id/ban')
  @HttpCode(204)
  async ban(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['admin', 'moderator'].includes(userRole)) throw new ForbiddenException('Insufficient role for ban');
    try {
      await this.cardService.ban(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/unban')
  @HttpCode(204)
  async unban(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['admin', 'moderator'].includes(userRole)) throw new ForbiddenException('Insufficient role for unban');
    try {
      await this.cardService.unban(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/restrict')
  @HttpCode(204)
  async restrict(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['admin', 'moderator'].includes(userRole)) throw new ForbiddenException('Insufficient role for restrict');
    try {
      await this.cardService.restrict(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/unrestrict')
  @HttpCode(204)
  async unrestrict(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['admin', 'moderator'].includes(userRole)) throw new ForbiddenException('Insufficient role for unrestrict');
    try {
      await this.cardService.unrestrict(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Put('/:id')
  async replace(@Param('id') id: string, @Body() body: any, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for replace');
    let result: any;
    try {
      result = await this.cardService.replace(Number(id), body.data);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Get('/:id/value')
  async calculate_value(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.cardService.calculate_value(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/rarity-bonus')
  async apply_rarity_bonus(@Param('id') id: string, @Body() body: any) {
    let result: any;
    try {
      result = await this.cardService.apply_rarity_bonus(Number(id), body.multiplier);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Get('/:id/legal')
  async is_legal_in_format(@Param('id') id: string, @Query('format') format: any) {
    let result: any;
    try {
      result = await this.cardService.is_legal_in_format(Number(id), format);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
