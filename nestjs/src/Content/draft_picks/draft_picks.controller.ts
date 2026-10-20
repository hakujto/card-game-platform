import { BadRequestException, Body, Controller, Get, HttpCode, NotFoundException, Param, Query, UnprocessableEntityException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { DraftPickService } from './draft_pick.service';


function validate(data: any): void {
  if (!((data.pickNumber == null || data.pickNumber > 0))) throw new Error(`Pick number must be greater than zero`);
  if (!((data.packNumber == null || (data.packNumber >= 1 && data.packNumber <= 3)))) throw new Error(`Pack number must be between 1 and 3`);
}
function applyProjection(obj: any): any {
  if (!obj) return obj;
  const r = { ...obj };
  if ('pickedAt' in r) { r.pickedAt = r.pickedAt; delete r.pickedAt; }
  return r;
}

@Controller('draft_picks')
export class DraftPickController {
  constructor(private readonly prisma: PrismaService, private readonly draftPickService: DraftPickService) {}

  @Get()
  async findAll() {
    const items = await this.prisma.draftPick.findMany();
    return items.map(applyProjection);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const entity = await this.prisma.draftPick.findUnique({ where: { id: Number(id) } });
    if (!entity) throw new NotFoundException('Not found');
    return applyProjection(entity);
  }

  @Get('/:id/first-pick')
  async is_first_pick(@Param('id') id: string) {
    let result: any;
    try {
      result = await this.draftPickService.is_first_pick(Number(id));
    } catch (err: any) {
      const msg = err?.message ?? 'Not found';
      if (msg.startsWith('Guard')) throw new UnprocessableEntityException(msg);
      throw new NotFoundException(msg);
    }
    return { result };
  }
}
