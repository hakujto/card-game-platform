package CardsProject::Schema::Result::TradeBid;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('trade_bids');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  amount => { data_type => 'numeric', size => [10, 2] },
  placed_at => { data_type => 'datetime' },
  is_winning => { data_type => 'boolean', default_value => 0 },
  listing_id => { data_type => 'integer', is_nullable => 1 },
  bidder_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'listing',
  'CardsProject::Schema::Result::TradeListing',
  { 'foreign.id' => 'self.listing_id' }
);
__PACKAGE__->belongs_to(
  'bidder',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.bidder_id' }
);

1;
