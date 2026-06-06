package CardsProject::Schema::Result::DraftParticipant;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('draft_participants');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  seat_number => { data_type => 'integer' },
  joined_at => { data_type => 'datetime' },
  session_id => { data_type => 'integer', is_nullable => 1 },
  player_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'session',
  'CardsProject::Schema::Result::DraftSession',
  { 'foreign.id' => 'self.session_id' }
);
__PACKAGE__->belongs_to(
  'player',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.player_id' }
);

1;
