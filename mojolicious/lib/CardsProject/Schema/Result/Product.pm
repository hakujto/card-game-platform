package CardsProject::Schema::Result::Product;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('products');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  name => { data_type => 'varchar', size => 200 },
  product_type => { data_type => 'varchar', size => 50, default_value => 'SingleCard' },
  price => { data_type => 'numeric', size => [10, 2] },
  stock => { data_type => 'integer', default_value => 0 },
  active => { data_type => 'boolean', default_value => 1 },
  discount_percent => { data_type => 'integer', default_value => 0 },
  description => { data_type => 'text', is_nullable => 1 },
  image_url => { data_type => 'varchar', is_nullable => 1 },
  featured => { data_type => 'boolean', default_value => 0 },
  card_id => { data_type => 'integer', is_nullable => 1, is_unique => 1 },
  card_set_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'card',
  'CardsProject::Schema::Result::Card',
  { 'foreign.id' => 'self.card_id' },
  { on_delete => 'SET NULL', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'card_set',
  'CardsProject::Schema::Result::CardSet',
  { 'foreign.id' => 'self.card_set_id' },
  { on_delete => 'SET NULL', on_update => 'CASCADE' }
);
__PACKAGE__->has_many('order_items' => 'CardsProject::Schema::Result::OrderItem', 'product_id');

1;
