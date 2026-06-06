package CardsProject::Schema::Result::Match;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('matches');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  table_number => { data_type => 'integer', is_nullable => 1 },
  status => { data_type => 'varchar', size => 50, default_value => 'Pending' },
  player1_wins => { data_type => 'integer', default_value => 0 },
  player2_wins => { data_type => 'integer', default_value => 0 },
  started_at => { data_type => 'datetime', is_nullable => 1 },
  ended_at => { data_type => 'datetime', is_nullable => 1 },
  result_notes => { data_type => 'text', is_nullable => 1 },
  round_id => { data_type => 'integer', is_nullable => 1 },
  player1_id => { data_type => 'integer', is_nullable => 1 },
  player2_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'round',
  'CardsProject::Schema::Result::TournamentRound',
  { 'foreign.id' => 'self.round_id' }
);
__PACKAGE__->belongs_to(
  'player1',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.player1_id' }
);
__PACKAGE__->belongs_to(
  'player2',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.player2_id' }
);

1;
