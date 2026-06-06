package CardsProject::Schema::Result::Game;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('games');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  game_number => { data_type => 'integer' },
  winner_side => { data_type => 'varchar', size => 50, is_nullable => 1 },
  turns_played => { data_type => 'integer', is_nullable => 1 },
  duration_seconds => { data_type => 'integer', is_nullable => 1 },
  ended_by => { data_type => 'varchar', size => 50, is_nullable => 1 },
  replay_url => { data_type => 'varchar', is_nullable => 1 },
  match_id => { data_type => 'integer', is_nullable => 1 },
  winner_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'match',
  'CardsProject::Schema::Result::Match',
  { 'foreign.id' => 'self.match_id' }
);
__PACKAGE__->belongs_to(
  'winner',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.winner_id' }
);

1;
