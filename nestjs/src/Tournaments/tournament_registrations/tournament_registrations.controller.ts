import { BadRequestException, Body, Controller, ForbiddenException, Get, HttpCode, NotFoundException, Param, Post, Query, Req, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TournamentRegistrationService } from './tournament_registration.service';


function validate(data: any): void {
  if (!((data.pointsEarned == null || data.pointsEarned >= 0))) throw new Error(`Points earned must not be negative`);
  if ((data.finalStanding != null) && !((data.finalStanding == null || data.finalStanding > 0))) throw new Error(`Final standing must be greater than zero`);
  if ((data.seed != null) && !((data.seed == null || data.seed > 0))) throw new Error(`Seed must be greater than zero`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('registeredAt' in r) { r.registeredAt = r.registeredAt; delete r.registeredAt; }
  return r;
}

@Controller('tournament_registrations')
export class TournamentRegistrationController {
  constructor(private readonly prisma: PrismaService, private readonly tournamentRegistrationService: TournamentRegistrationService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.tournamentRegistration.findMany();
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.status !== undefined) data.status = body.status;
    if (body.seed !== undefined) data.seed = body.seed;
    if (body.finalStanding !== undefined) data.finalStanding = body.finalStanding;
    if (body.pointsEarned !== undefined) data.pointsEarned = body.pointsEarned;
    if (body.registeredAt !== undefined) data.registeredAt = body.registeredAt != null ? new Date(body.registeredAt) : null;
    if (body.tournamentId !== undefined) data.tournamentId = body.tournamentId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    if (body.deckId !== undefined) data.deckId = body.deckId;
    try {
    validate(data);
      const entity = await this.prisma.tournamentRegistration.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string, @Req() request: any) {
    const entity = await this.prisma.tournamentRegistration.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    if (entity.playerId !== (request as any).userId) throw new ForbiddenException('You do not own this resource.');
    return applyProjection(entity);
  }

  @Post('/:id/withdraw')
  @HttpCode(204)
  async withdraw(@Param('id') id: string) {
    try {
      await this.tournamentRegistrationService.withdraw(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/disqualify')
  @HttpCode(204)
  async disqualify(@Param('id') id: string, @Body() body: any) {
    try {
      await this.tournamentRegistrationService.disqualify(Number(id), body.reason);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Post('/:id/promote')
  @HttpCode(204)
  async promote_from_waitlist(@Param('id') id: string) {
    try {
      await this.tournamentRegistrationService.promote_from_waitlist(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }
}
