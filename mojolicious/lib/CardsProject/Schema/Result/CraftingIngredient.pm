package CardsProject::Schema::Result::CraftingIngredient;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('crafting_ingredients');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  quantity => { data_type => 'integer', default_value => 1 },
  recipe_id => { data_type => 'integer', is_nullable => 1 },
  card_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'recipe',
  'CardsProject::Schema::Result::CraftingRecipe',
  { 'foreign.id' => 'self.recipe_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'card',
  'CardsProject::Schema::Result::Card',
  { 'foreign.id' => 'self.card_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);

1;
