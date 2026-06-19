package CardsProject::Schema::Result::TournamentJudge;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('tournament_judges');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  role => { data_type => 'varchar', size => 50, default_value => 'Judge' },
  tournament_id => { data_type => 'integer', is_nullable => 1 },
  player_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'tournament',
  'CardsProject::Schema::Result::Tournament',
  { 'foreign.id' => 'self.tournament_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'player',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.player_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);

1;
