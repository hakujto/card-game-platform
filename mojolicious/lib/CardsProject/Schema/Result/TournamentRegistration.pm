package CardsProject::Schema::Result::TournamentRegistration;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('tournament_registrations');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  status => { data_type => 'varchar', size => 50, default_value => 'Registered' },
  seed => { data_type => 'integer', is_nullable => 1 },
  final_standing => { data_type => 'integer', is_nullable => 1 },
  points_earned => { data_type => 'integer', default_value => 0 },
  registered_at => { data_type => 'datetime' },
  tournament_id => { data_type => 'integer', is_nullable => 1 },
  player_id => { data_type => 'integer', is_nullable => 1 },
  deck_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'tournament',
  'CardsProject::Schema::Result::Tournament',
  { 'foreign.id' => 'self.tournament_id' }
);
__PACKAGE__->belongs_to(
  'player',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.player_id' }
);
__PACKAGE__->belongs_to(
  'deck',
  'CardsProject::Schema::Result::Deck',
  { 'foreign.id' => 'self.deck_id' }
);

1;
