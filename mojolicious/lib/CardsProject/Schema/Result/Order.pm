package CardsProject::Schema::Result::Order;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('orders');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  status => { data_type => 'varchar', size => 50, default_value => 'Pending' },
  total => { data_type => 'numeric', size => [10, 2], default_value => 0 },
  discount_applied => { data_type => 'numeric', size => [10, 2], default_value => 0 },
  currency => { data_type => 'varchar', size => 3, default_value => 'USD' },
  payment_method => { data_type => 'varchar', size => 50, is_nullable => 1 },
  payment_reference => { data_type => 'varchar', size => 200, is_nullable => 1 },
  shipping_address => { data_type => 'text', is_nullable => 1 },
  tracking_number => { data_type => 'varchar', size => 100, is_nullable => 1 },
  created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  paid_at => { data_type => 'datetime', is_nullable => 1 },
  shipped_at => { data_type => 'datetime', is_nullable => 1 },
  player_id => { data_type => 'integer', is_nullable => 1 },
  coupon_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'player',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.player_id' }
);
__PACKAGE__->belongs_to(
  'coupon',
  'CardsProject::Schema::Result::Coupon',
  { 'foreign.id' => 'self.coupon_id' }
);

sub notify_status_change { }

1;
