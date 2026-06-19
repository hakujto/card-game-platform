package CardsProject::Schema::Result::DraftPick;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('draft_picks');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  pick_number => { data_type => 'integer' },
  pack_number => { data_type => 'integer' },
  picked_at => { data_type => 'datetime' },
  participant_id => { data_type => 'integer', is_nullable => 1 },
  card_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'participant',
  'CardsProject::Schema::Result::DraftParticipant',
  { 'foreign.id' => 'self.participant_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'card',
  'CardsProject::Schema::Result::Card',
  { 'foreign.id' => 'self.card_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);

1;
