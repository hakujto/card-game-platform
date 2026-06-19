package CardsProject::Schema::Result::TournamentPrize;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('tournament_prizes');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  placement_from => { data_type => 'integer' },
  placement_to => { data_type => 'integer' },
  prize_type => { data_type => 'varchar', size => 50 },
  amount => { data_type => 'numeric', size => [10, 2], default_value => 0 },
  description => { data_type => 'text', is_nullable => 1 },
  packs_count => { data_type => 'integer', is_nullable => 1 },
  season_points => { data_type => 'integer', default_value => 0 },
  tournament_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'tournament',
  'CardsProject::Schema::Result::Tournament',
  { 'foreign.id' => 'self.tournament_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->has_many('awarded_prizes' => 'CardsProject::Schema::Result::AwardedPrize', 'prize_id');

1;
