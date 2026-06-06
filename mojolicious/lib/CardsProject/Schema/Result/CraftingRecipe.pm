package CardsProject::Schema::Result::CraftingRecipe;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('crafting_recipes');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  dust_cost => { data_type => 'integer' },
  is_available => { data_type => 'boolean', default_value => 1 },
  result_card_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'result_card',
  'CardsProject::Schema::Result::Card',
  { 'foreign.id' => 'self.result_card_id' }
);
__PACKAGE__->many_to_many('cards', 'card_links', 'card');

1;
