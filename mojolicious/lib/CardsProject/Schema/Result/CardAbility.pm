package CardsProject::Schema::Result::CardAbility;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('card_abilities');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  ability_type => { data_type => 'varchar', size => 50, default_value => 'Keyword' },
  keyword => { data_type => 'varchar', size => 100, is_nullable => 1 },
  ability_text => { data_type => 'text' },
  timing => { data_type => 'varchar', size => 50, is_nullable => 1 },
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
