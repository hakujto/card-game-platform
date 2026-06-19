package CardsProject::Schema::Result::ArticleTagAssignment;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('article_tag_assignments');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  article_id => { data_type => 'integer', is_nullable => 1 },
  tag_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'article',
  'CardsProject::Schema::Result::Article',
  { 'foreign.id' => 'self.article_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'tag',
  'CardsProject::Schema::Result::ArticleTag',
  { 'foreign.id' => 'self.tag_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);

1;
