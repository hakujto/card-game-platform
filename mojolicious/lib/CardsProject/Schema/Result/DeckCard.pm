package CardsProject::Schema::Result::DeckCard;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('deck_cards');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  quantity => { data_type => 'integer', default_value => 1 },
  is_commander => { data_type => 'boolean', default_value => 0 },
  deck_id => { data_type => 'integer', is_nullable => 1 },
  card_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'deck',
  'CardsProject::Schema::Result::Deck',
  { 'foreign.id' => 'self.deck_id' }
);
__PACKAGE__->belongs_to(
  'card',
  'CardsProject::Schema::Result::Card',
  { 'foreign.id' => 'self.card_id' }
);

1;
