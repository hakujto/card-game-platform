package CardsProject::Schema::Result::CardRuling;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('card_rulings');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  ruling_text => { data_type => 'text' },
  published_at => { data_type => 'date' },
  source => { data_type => 'varchar', size => 200 },
  card_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'card',
  'CardsProject::Schema::Result::Card',
  { 'foreign.id' => 'self.card_id' }
);

1;
