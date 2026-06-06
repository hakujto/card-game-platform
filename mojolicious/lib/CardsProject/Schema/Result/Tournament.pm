package CardsProject::Schema::Result::Tournament;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('tournaments');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  name => { data_type => 'varchar', size => 200 },
  description => { data_type => 'text', is_nullable => 1 },
  status => { data_type => 'varchar', size => 50, default_value => 'Draft' },
  format => { data_type => 'varchar', size => 50, default_value => 'Standard' },
  tournament_type => { data_type => 'varchar', size => 50, default_value => 'Swiss' },
  max_players => { data_type => 'integer' },
  entry_fee => { data_type => 'numeric', size => [10, 2], default_value => 0 },
  prize_pool => { data_type => 'numeric', size => [10, 2], default_value => 0 },
  start_time => { data_type => 'datetime' },
  end_time => { data_type => 'datetime', is_nullable => 1 },
  is_online => { data_type => 'boolean', default_value => 1 },
  location => { data_type => 'varchar', size => 300, is_nullable => 1 },
  rules_text => { data_type => 'text', is_nullable => 1 },
  created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  season_id => { data_type => 'integer', is_nullable => 1 },
  organizer_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'season',
  'CardsProject::Schema::Result::Season',
  { 'foreign.id' => 'self.season_id' }
);
__PACKAGE__->belongs_to(
  'organizer',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.organizer_id' }
);
__PACKAGE__->many_to_many('players', 'player_links', 'player');

sub sync_season_stats { }

1;
