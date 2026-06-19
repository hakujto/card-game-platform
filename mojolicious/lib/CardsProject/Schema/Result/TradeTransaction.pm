package CardsProject::Schema::Result::TradeTransaction;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('trade_transactions');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  final_price => { data_type => 'numeric', size => [10, 2] },
  platform_fee => { data_type => 'numeric', size => [10, 2] },
  status => { data_type => 'varchar', size => 50, default_value => 'Pending' },
  completed_at => { data_type => 'datetime', is_nullable => 1 },
  listing_id => { data_type => 'integer', is_nullable => 1, is_unique => 1 },
  buyer_id => { data_type => 'integer', is_nullable => 1 },
  seller_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'listing',
  'CardsProject::Schema::Result::TradeListing',
  { 'foreign.id' => 'self.listing_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'buyer',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.buyer_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'seller',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.seller_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);
__PACKAGE__->might_have('dispute' => 'CardsProject::Schema::Result::TradeDispute', 'transaction_id');

1;
