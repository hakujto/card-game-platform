package CardsProject::Schema::Result::TournamentRound;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('tournament_rounds');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  round_number => { data_type => 'integer' },
  status => { data_type => 'varchar', size => 50, default_value => 'Pending' },
  started_at => { data_type => 'datetime', is_nullable => 1 },
  ended_at => { data_type => 'datetime', is_nullable => 1 },
  time_limit_minutes => { data_type => 'integer', default_value => 50 },
  tournament_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'tournament',
  'CardsProject::Schema::Result::Tournament',
  { 'foreign.id' => 'self.tournament_id' }
);

1;
