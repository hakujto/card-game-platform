package CardsProject::Schema::Result::DraftSession;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('draft_sessions');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  status => { data_type => 'varchar', size => 50, default_value => 'WaitingForPlayers' },
  draft_type => { data_type => 'varchar', size => 50, default_value => 'Booster' },
  seats => { data_type => 'integer', default_value => 8 },
  time_per_pick_seconds => { data_type => 'integer', default_value => 30 },
  created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  completed_at => { data_type => 'datetime', is_nullable => 1 },
  card_set_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'card_set',
  'CardsProject::Schema::Result::CardSet',
  { 'foreign.id' => 'self.card_set_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);
__PACKAGE__->has_many('participants' => 'CardsProject::Schema::Result::DraftParticipant', 'session_id');

1;
