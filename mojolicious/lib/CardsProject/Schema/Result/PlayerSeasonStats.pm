package CardsProject::Schema::Result::PlayerSeasonStats;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('player_season_statses');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  wins => { data_type => 'integer', default_value => 0 },
  losses => { data_type => 'integer', default_value => 0 },
  draws => { data_type => 'integer', default_value => 0 },
  tournament_wins => { data_type => 'integer', default_value => 0 },
  highest_rank => { data_type => 'varchar', size => 50, is_nullable => 1 },
  season_points => { data_type => 'integer', default_value => 0 },
  player_id => { data_type => 'integer', is_nullable => 1 },
  season_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'player',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.player_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'season',
  'CardsProject::Schema::Result::Season',
  { 'foreign.id' => 'self.season_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);

1;
