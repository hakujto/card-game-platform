package CardsProject::Schema::Result::OrderItem;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('order_items');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  quantity => { data_type => 'integer' },
  price_at_purchase => { data_type => 'numeric', size => [10, 2] },
  foil => { data_type => 'boolean', default_value => 0 },
  order_id => { data_type => 'integer', is_nullable => 1 },
  product_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'order',
  'CardsProject::Schema::Result::Order',
  { 'foreign.id' => 'self.order_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'product',
  'CardsProject::Schema::Result::Product',
  { 'foreign.id' => 'self.product_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);

1;
