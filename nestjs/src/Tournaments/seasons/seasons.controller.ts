import { BadRequestException, Body, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Patch, Post, Put, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { SeasonService } from './season.service';


function validate(data: any): void {
  if (!((data.endDate == null || (data.startDate != null && data.endDate > data.startDate)))) throw new Error(`Season end date must be after start date`);
}

@Controller('seasons')
export class SeasonController {
  constructor(private readonly prisma: PrismaService, private readonly seasonService: SeasonService) {}

  @Get()
  async findAll(@Query('q') q?: string) {
    const where = q ? { OR: [{ name: { contains: q } }] } : undefined;
    const items = await this.prisma.season.findMany(where ? { where } : undefined);
    return items;
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.startDate !== undefined) data.startDate = body.startDate != null ? new Date(body.startDate) : null;
    if (body.endDate !== undefined) data.endDate = body.endDate != null ? new Date(body.endDate) : null;
    if (body.format !== undefined) data.format = body.format;
    if (body.isActive !== undefined) data.isActive = body.isActive;
    if (body.rewardDescription !== undefined) data.rewardDescription = body.rewardDescription;
    try {
    validate(data);
      const entity = await this.prisma.season.create({ data });
      return entity;
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.season.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return entity;
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    const data: any = {};
    if (body.name !== undefined) data.name = body.name;
    if (body.startDate !== undefined) data.startDate = body.startDate != null ? new Date(body.startDate) : null;
    if (body.endDate !== undefined) data.endDate = body.endDate != null ? new Date(body.endDate) : null;
    if (body.format !== undefined) data.format = body.format;
    if (body.isActive !== undefined) data.isActive = body.isActive;
    if (body.rewardDescription !== undefined) data.rewardDescription = body.rewardDescription;
    try {
    validate(data);
      const existing = await this.prisma.season.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.season.update({ where: { id: Number(id) }, data });
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
    if (body.name !== undefined) data.name = body.name;
    if (body.startDate !== undefined) data.startDate = body.startDate != null ? new Date(body.startDate) : null;
    if (body.endDate !== undefined) data.endDate = body.endDate != null ? new Date(body.endDate) : null;
    if (body.format !== undefined) data.format = body.format;
    if (body.isActive !== undefined) data.isActive = body.isActive;
    if (body.rewardDescription !== undefined) data.rewardDescription = body.rewardDescription;
    try {
    validate(data);
      const existing = await this.prisma.season.findUnique({ where: { id: Number(id) } });
      if (!existing) throw new NotFoundException('Not found');
      const entity = await this.prisma.season.update({ where: { id: Number(id) }, data });
      return entity;
    } catch (err: any) {
      if (err instanceof NotFoundException || err instanceof ForbiddenException) throw err;
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Error');
    }
  }

  @Post('/:id/activate')
  @HttpCode(204)
  async activate(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for activate');
    try {
      await this.seasonService.activate(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/deactivate')
  @HttpCode(204)
  async deactivate(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for deactivate');
    try {
      await this.seasonService.deactivate(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/finalize')
  @HttpCode(204)
  async finalize_rewards(@Param('id') id: string, @Req() request: any) {
    const userRole = request?.user?.role;
    if (!['admin'].includes(userRole)) throw new ForbiddenException('Insufficient role for finalize_rewards');
    try {
      await this.seasonService.finalize_rewards(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/ongoing')
  async is_ongoing(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.seasonService.is_ongoing(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
