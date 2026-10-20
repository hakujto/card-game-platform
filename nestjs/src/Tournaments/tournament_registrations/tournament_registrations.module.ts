import { Module } from '@nestjs/common';
import { TournamentRegistrationController } from './tournament_registrations.controller';
import { TournamentRegistrationService } from './tournament_registration.service';

@Module({
  controllers: [TournamentRegistrationController],
  providers: [TournamentRegistrationService],
})
export class TournamentRegistrationModule {}
