package CardsProject::Schema::Result::TradeListing;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('trade_listings');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  status => { data_type => 'varchar', size => 50, default_value => 'Active' },
  listing_type => { data_type => 'varchar', size => 50, default_value => 'FixedPrice' },
  asking_price => { data_type => 'numeric', size => [10, 2], is_nullable => 1 },
  auction_start_price => { data_type => 'numeric', size => [10, 2], is_nullable => 1 },
  auction_current_bid => { data_type => 'numeric', size => [10, 2], is_nullable => 1 },
  auction_end_time => { data_type => 'datetime', is_nullable => 1 },
  foil => { data_type => 'boolean', default_value => 0 },
  condition => { data_type => 'varchar', size => 50, default_value => 'Mint' },
  quantity => { data_type => 'integer', default_value => 1 },
  description => { data_type => 'text', is_nullable => 1 },
  created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  expires_at => { data_type => 'datetime', is_nullable => 1 },
  seller_id => { data_type => 'integer', is_nullable => 1 },
  card_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'seller',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.seller_id' }
);
__PACKAGE__->belongs_to(
  'card',
  'CardsProject::Schema::Result::Card',
  { 'foreign.id' => 'self.card_id' }
);

1;
