import { BadRequestException, Body, Controller, Get, HttpCode, NotFoundException, Param, Post, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { DraftParticipantService } from './draft_participant.service';


function validate(data: any): void {
  if (!((data.seatNumber == null || data.seatNumber > 0))) throw new Error(`Seat number must be greater than zero`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('joinedAt' in r) { r.joinedAt = r.joinedAt; delete r.joinedAt; }
  return r;
}

@Controller('draft_participants')
export class DraftParticipantController {
  constructor(private readonly prisma: PrismaService, private readonly draftParticipantService: DraftParticipantService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.draftParticipant.findMany();
    return items.map(applyProjection);
  }

  @Post()
  async create(@Body() body: any) {
    const data: any = {};
    if (body.seatNumber !== undefined) data.seatNumber = body.seatNumber;
    if (body.joinedAt !== undefined) data.joinedAt = body.joinedAt != null ? new Date(body.joinedAt) : null;
    if (body.sessionId !== undefined) data.sessionId = body.sessionId;
    if (body.playerId !== undefined) data.playerId = body.playerId;
    try {
    validate(data);
      const entity = await this.prisma.draftParticipant.create({ data });
      return applyProjection(entity);
    } catch (err: any) {
      if (err?.code === 'P2002') throw new BadRequestException('Value must be unique');
      throw new BadRequestException(err?.message ?? 'Validation error');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.draftParticipant.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Post('/:id/pick')
  @HttpCode(204)
  async pick_card(@Param('id') id: string, @Body() body: any) {
    try {
      await this.draftParticipantService.pick_card(Number(id), body.cardId, body.packNumber);
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
  }

  @Get('/:id/card-count')
  async drafted_card_count(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.draftParticipantService.drafted_card_count(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
