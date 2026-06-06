package CardsProject::Schema::Result::DeckTagAssignment;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('deck_tag_assignments');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  deck_id => { data_type => 'integer', is_nullable => 1 },
  tag_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'deck',
  'CardsProject::Schema::Result::Deck',
  { 'foreign.id' => 'self.deck_id' }
);
__PACKAGE__->belongs_to(
  'tag',
  'CardsProject::Schema::Result::DeckTag',
  { 'foreign.id' => 'self.tag_id' }
);

1;
