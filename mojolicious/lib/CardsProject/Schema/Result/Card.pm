package CardsProject::Schema::Result::Card;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('cards');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  name => { data_type => 'varchar', size => 200 },
  card_type => { data_type => 'varchar', size => 50, default_value => 'Creature' },
  rarity => { data_type => 'varchar', size => 50, default_value => 'Common' },
  mana_cost => { data_type => 'integer', default_value => 0 },
  mana_colors => { data_type => 'varchar', size => 50 },
  attack => { data_type => 'integer', is_nullable => 1 },
  defense => { data_type => 'integer', is_nullable => 1 },
  loyalty => { data_type => 'integer', is_nullable => 1 },
  description => { data_type => 'text' },
  flavor_text => { data_type => 'text', is_nullable => 1 },
  image_url => { data_type => 'varchar', is_nullable => 1 },
  artist_name => { data_type => 'varchar', size => 100, is_nullable => 1 },
  legal_formats => { data_type => 'varchar', size => 50 },
  is_banned => { data_type => 'boolean', default_value => 0 },
  is_restricted => { data_type => 'boolean', default_value => 0 },
  power_level => { data_type => 'integer', default_value => 1 },
  set_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'set',
  'CardsProject::Schema::Result::CardSet',
  { 'foreign.id' => 'self.set_id' }
);

sub insert {
  my ($self, @args) = @_;
  &validate_legality($self);
  return $self->next::method(@args);
}

sub validate_legality { }

1;
