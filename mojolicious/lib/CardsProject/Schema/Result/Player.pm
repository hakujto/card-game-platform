package CardsProject::Schema::Result::Player;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('players');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  display_name => { data_type => 'varchar', size => 50 },
  rank => { data_type => 'varchar', size => 50, default_value => 'Bronze' },
  rating => { data_type => 'integer', default_value => 1000 },
  peak_rating => { data_type => 'integer', default_value => 1000 },
  bio => { data_type => 'text', is_nullable => 1 },
  country_code => { data_type => 'varchar', size => 2, is_nullable => 1 },
  avatar_url => { data_type => 'varchar', is_nullable => 1 },
  preferred_format => { data_type => 'varchar', size => 50, is_nullable => 1 },
  is_verified => { data_type => 'boolean', default_value => 0 },
  created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  last_active_at => { data_type => 'datetime', is_nullable => 1 },
  user_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'user',
  'CardsProject::Schema::Result::User',
  { 'foreign.id' => 'self.user_id' }
);
__PACKAGE__->many_to_many('achievements', 'achievement_links', 'achievement');
__PACKAGE__->many_to_many('players', 'player_links', 'player');

sub update_rank { }

1;
