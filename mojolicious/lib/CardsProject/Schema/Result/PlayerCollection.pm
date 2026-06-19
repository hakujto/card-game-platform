package CardsProject::Schema::Result::PlayerCollection;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('player_collections');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  quantity => { data_type => 'integer', default_value => 1 },
  foil => { data_type => 'boolean', default_value => 0 },
  condition => { data_type => 'varchar', size => 50, default_value => 'Mint' },
  acquired_at => { data_type => 'datetime' },
  acquired_via => { data_type => 'varchar', size => 50, default_value => 'Purchase' },
  player_id => { data_type => 'integer', is_nullable => 1 },
  card_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'player',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.player_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'card',
  'CardsProject::Schema::Result::Card',
  { 'foreign.id' => 'self.card_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);

1;
