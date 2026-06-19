package CardsProject::Schema::Result::CardPriceHistory;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('card_price_histories');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  price_date => { data_type => 'date' },
  avg_price => { data_type => 'numeric', size => [10, 2] },
  min_price => { data_type => 'numeric', size => [10, 2] },
  max_price => { data_type => 'numeric', size => [10, 2] },
  volume => { data_type => 'integer' },
  foil => { data_type => 'boolean', default_value => 0 },
  card_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'card',
  'CardsProject::Schema::Result::Card',
  { 'foreign.id' => 'self.card_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);

1;
