package CardsProject::Schema::Result::Card;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('cards');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  public_id => { data_type => 'varchar', is_unique => 1 },
  name => { data_type => 'varchar', size => 200 },
  card_type => { data_type => 'varchar', size => 50, default_value => 'Creature' },
  rarity => { data_type => 'varchar', size => 50, default_value => 'Common' },
  mana_cost => { data_type => 'integer', default_value => 0 },
  mana_colors => { data_type => 'varchar', size => 50 },
  attack => { data_type => 'integer', is_nullable => 1 },
  defense => { data_type => 'integer', is_nullable => 1 },
  loyalty => { data_type => 'integer', is_nullable => 1 },
  description => { data_type => 'text' },
  flavor_text => { data_type => 'text', is_nullable => 1 },
  image_url => { data_type => 'varchar', is_nullable => 1 },
  artist_name => { data_type => 'varchar', size => 100, is_nullable => 1 },
  legal_formats => { data_type => 'varchar', size => 50 },
  is_banned => { data_type => 'boolean', default_value => 0 },
  is_restricted => { data_type => 'boolean', default_value => 0 },
  power_level => { data_type => 'integer', default_value => 1 },
  metadata => { data_type => 'text', is_nullable => 1 },
  total_copies_in_circulation => { data_type => 'bigint', default_value => 0 },
  set_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'set',
  'CardsProject::Schema::Result::CardSet',
  { 'foreign.id' => 'self.set_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);
__PACKAGE__->has_many('rulings' => 'CardsProject::Schema::Result::CardRuling', 'card_id');
__PACKAGE__->has_many('abilities' => 'CardsProject::Schema::Result::CardAbility', 'card_id');
__PACKAGE__->has_many('deck_cards' => 'CardsProject::Schema::Result::DeckCard', 'card_id');
__PACKAGE__->has_many('player_collections' => 'CardsProject::Schema::Result::PlayerCollection', 'card_id');
__PACKAGE__->has_many('crafting_recipes' => 'CardsProject::Schema::Result::CraftingRecipe', 'result_card_id');
__PACKAGE__->has_many('used_in_recipes' => 'CardsProject::Schema::Result::CraftingIngredient', 'card_id');
__PACKAGE__->might_have('shop_product' => 'CardsProject::Schema::Result::Product', 'card_id');
__PACKAGE__->has_many('trade_listings' => 'CardsProject::Schema::Result::TradeListing', 'card_id');
__PACKAGE__->has_many('price_history' => 'CardsProject::Schema::Result::CardPriceHistory', 'card_id');
__PACKAGE__->has_many('draft_picks' => 'CardsProject::Schema::Result::DraftPick', 'card_id');

sub insert {
  my ($self, @args) = @_;
  &validate_legality($self);
  return $self->next::method(@args);
}

sub validate_legality { }

sub validate_not_in_use { }

1;
