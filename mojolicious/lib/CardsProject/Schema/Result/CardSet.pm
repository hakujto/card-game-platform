package CardsProject::Schema::Result::CardSet;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('card_sets');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  name => { data_type => 'varchar', size => 200 },
  code => { data_type => 'varchar', size => 10, is_unique => 1 },
  release_date => { data_type => 'date' },
  rotation_date => { data_type => 'date', is_nullable => 1 },
  set_type => { data_type => 'varchar', size => 50, default_value => 'Expansion' },
  total_cards => { data_type => 'integer' },
  is_rotated => { data_type => 'boolean', default_value => 0 },
  description => { data_type => 'text', is_nullable => 1 },
  logo_url => { data_type => 'varchar', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many('cards' => 'CardsProject::Schema::Result::Card', 'set_id');
__PACKAGE__->has_many('shop_products' => 'CardsProject::Schema::Result::Product', 'card_set_id');
__PACKAGE__->has_many('draft_sessions' => 'CardsProject::Schema::Result::DraftSession', 'card_set_id');

1;
