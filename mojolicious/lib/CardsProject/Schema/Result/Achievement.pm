package CardsProject::Schema::Result::Achievement;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('achievements');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  name => { data_type => 'varchar', size => 200 },
  description => { data_type => 'text' },
  icon_url => { data_type => 'varchar', is_nullable => 1 },
  points => { data_type => 'integer', default_value => 10 },
  rarity => { data_type => 'varchar', size => 50, default_value => 'Common' },
  is_hidden => { data_type => 'boolean', default_value => 0 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many('player_records' => 'CardsProject::Schema::Result::PlayerAchievement', 'achievement_id');

1;
