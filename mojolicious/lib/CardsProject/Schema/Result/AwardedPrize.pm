package CardsProject::Schema::Result::AwardedPrize;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('awarded_prizes');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  final_placement => { data_type => 'integer' },
  awarded_at => { data_type => 'datetime' },
  claimed => { data_type => 'boolean', default_value => 0 },
  claimed_at => { data_type => 'datetime', is_nullable => 1 },
  prize_id => { data_type => 'integer', is_nullable => 1 },
  player_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'prize',
  'CardsProject::Schema::Result::TournamentPrize',
  { 'foreign.id' => 'self.prize_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'player',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.player_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);

1;
