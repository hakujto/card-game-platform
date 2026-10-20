import { BadRequestException, Body, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { PlayerService } from './player.service';


function validate(data: any): void {
  if (data.countryCode != null && !/[A-Z]{2}/.test(String(data.countryCode))) throw new Error('country_code: invalid format');
  if (!((data.rating == null || (data.rating >= 0 && data.rating <= 9999)))) throw new Error(`Rating must be between 0 and 9999`);
  if (!((data.peakRating == null || (data.rating != null && data.peakRating >= data.rating)))) throw new Error(`Peak rating must be greater than or equal to current rating`);
  if (!((data.displayName === undefined || data.displayName != null))) throw new Error(`Display name must not be empty`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('createdAt' in r) { r.createdAt = r.createdAt; delete r.createdAt; }
  if ('lastActiveAt' in r) { r.lastActiveAt = r.lastActiveAt; delete r.lastActiveAt; }
  return r;
}

@Controller('players')
export class PlayerController {
  constructor(private readonly prisma: PrismaService, private readonly playerService: PlayerService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ displayName: { contains: q } }] } : undefined;
    const items = await this.prisma.player.findMany(where ? { where } : undefined);
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.publicId !== undefined) data.publicId = body.publicId;
    if (body.displayName !== undefined) data.displayName = body.displayName;
    if (body.rank !== undefined) data.rank = body.rank;
    if (body.rating !== undefined) data.rating = body.rating;
    if (body.peakRating !== undefined) data.peakRating = body.peakRating;
    if (body.bio !== undefined) data.bio = body.bio;
    if (body.countryCode !== undefined) data.countryCode = body.countryCode;
    if (body.avatarUrl !== undefined) data.avatarUrl = body.avatarUrl;
    if (body.preferredFormat !== undefined) data.preferredFormat = body.preferredFormat;
    if (body.contactEmail !== undefined) data.contactEmail = body.contactEmail;
    if (body.winRateCached !== undefined) data.winRateCached = body.winRateCached;
    if (body.isVerified !== undefined) data.isVerified = body.isVerified;
    if (body.createdAt !== undefined) data.createdAt = body.createdAt != null ? new Date(body.createdAt) : null;
    if (body.lastActiveAt !== undefined) data.lastActiveAt = body.lastActiveAt != null ? new Date(body.lastActiveAt) : null;
    if (body.userId !== undefined) data.userId = body.userId;
    try {
    validate(data);
      const entity = await this.prisma.player.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.player.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Patch(':id')
  async partialUpdate(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.publicId !== undefined) data.publicId = body.publicId;
    if (body.displayName !== undefined) data.displayName = body.displayName;
    if (body.rank !== undefined) data.rank = body.rank;
    if (body.bio !== undefined) data.bio = body.bio;
    if (body.countryCode !== undefined) data.countryCode = body.countryCode;
    if (body.avatarUrl !== undefined) data.avatarUrl = body.avatarUrl;
    if (body.preferredFormat !== undefined) data.preferredFormat = body.preferredFormat;
    if (body.contactEmail !== undefined) data.contactEmail = body.contactEmail;
    if (body.winRateCached !== undefined) data.winRateCached = body.winRateCached;
    if (body.isVerified !== undefined) data.isVerified = body.isVerified;
    if (body.lastActiveAt !== undefined) data.lastActiveAt = body.lastActiveAt != null ? new Date(body.lastActiveAt) : null;
    if (body.userId !== undefined) data.userId = body.userId;
    try {
    validate(data);
      const existing = await this.prisma.player.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.player.update({ where: { id: Number(id) }, data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Post('/:id/promote')
  async promote(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.playerService.promote(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/demote')
  async demote(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.playerService.demote(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/win')
  @HttpCode(204)
  async record_win(@Param('id') id: string) {
    try {
      await this.playerService.record_win(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/loss')
  @HttpCode(204)
  async record_loss(@Param('id') id: string) {
    try {
      await this.playerService.record_loss(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/win-rate')
  async win_rate(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.playerService.win_rate(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }

  @Post('/:id/verify')
  @HttpCode(204)
  async verify(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for verify');
    try {
      await this.playerService.verify(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Patch('/:id/rating')
  @HttpCode(204)
  async update_rating(@Param('id') id: string, @Body() body: any) {
    try {
      await this.playerService.update_rating(Number(id), body.delta);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
