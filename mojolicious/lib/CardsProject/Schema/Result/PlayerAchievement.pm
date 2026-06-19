package CardsProject::Schema::Result::PlayerAchievement;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('player_achievements');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  earned_at => { data_type => 'datetime' },
  progress => { data_type => 'integer', default_value => 0 },
  is_completed => { data_type => 'boolean', default_value => 0 },
  player_id => { data_type => 'integer', is_nullable => 1 },
  achievement_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'player',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.player_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'achievement',
  'CardsProject::Schema::Result::Achievement',
  { 'foreign.id' => 'self.achievement_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);

1;
