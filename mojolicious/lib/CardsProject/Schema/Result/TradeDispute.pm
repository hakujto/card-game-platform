package CardsProject::Schema::Result::TradeDispute;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('trade_disputes');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  status => { data_type => 'varchar', size => 50, default_value => 'Open' },
  reason => { data_type => 'varchar', size => 50 },
  description => { data_type => 'text' },
  resolution => { data_type => 'text', is_nullable => 1 },
  opened_at => { data_type => 'datetime' },
  resolved_at => { data_type => 'datetime', is_nullable => 1 },
  transaction_id => { data_type => 'integer', is_nullable => 1 },
  opened_by_id => { data_type => 'integer', is_nullable => 1 },
  resolved_by_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'transaction',
  'CardsProject::Schema::Result::TradeTransaction',
  { 'foreign.id' => 'self.transaction_id' }
);
__PACKAGE__->belongs_to(
  'opened_by',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.opened_by_id' }
);
__PACKAGE__->belongs_to(
  'resolved_by',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.resolved_by_id' }
);

1;
