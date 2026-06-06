package CardsProject::Schema::Result::User;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('users');

__PACKAGE__->add_columns(
  id       => { data_type => 'integer', is_auto_increment => 1 },
  email    => { data_type => 'varchar', size => 255 },
  password => { data_type => 'varchar', size => 255 }
);

__PACKAGE__->set_primary_key('id');

1;
