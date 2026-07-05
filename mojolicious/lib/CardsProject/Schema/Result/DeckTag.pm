package CardsProject::Schema::Result::DeckTag;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('deck_tags');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  name => { data_type => 'varchar', size => 50 },
  slug => { data_type => 'varchar', is_nullable => 1 },
  color => { data_type => 'varchar', size => 7, is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many('deck_assignments' => 'CardsProject::Schema::Result::DeckTagAssignment', 'tag_id');

1;
