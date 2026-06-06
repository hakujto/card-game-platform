package CardsProject::Schema::Result::Coupon;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('coupons');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  code => { data_type => 'varchar', size => 50 },
  discount_type => { data_type => 'varchar', size => 50, default_value => 'Percent' },
  discount_value => { data_type => 'numeric', size => [10, 2] },
  min_order_value => { data_type => 'numeric', size => [10, 2], default_value => 0 },
  max_uses => { data_type => 'integer', is_nullable => 1 },
  uses_count => { data_type => 'integer', default_value => 0 },
  valid_from => { data_type => 'datetime' },
  valid_until => { data_type => 'datetime' },
  is_active => { data_type => 'boolean', default_value => 1 }
);

__PACKAGE__->set_primary_key('id');


1;
