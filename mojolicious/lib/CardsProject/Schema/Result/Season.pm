package CardsProject::Schema::Result::Season;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('seasons');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  name => { data_type => 'varchar', size => 200 },
  start_date => { data_type => 'date' },
  end_date => { data_type => 'date' },
  format => { data_type => 'varchar', size => 50, default_value => 'Standard' },
  is_active => { data_type => 'boolean', default_value => 0 },
  reward_description => { data_type => 'text', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many('player_stats' => 'CardsProject::Schema::Result::PlayerSeasonStats', 'season_id');
__PACKAGE__->has_many('tournaments' => 'CardsProject::Schema::Result::Tournament', 'season_id');

1;
