package CardsProject::Schema::Result::ArticleTag;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('article_tags');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  name => { data_type => 'varchar', size => 100 },
  slug => { data_type => 'varchar', size => 100 }
);

__PACKAGE__->set_primary_key('id');


1;
