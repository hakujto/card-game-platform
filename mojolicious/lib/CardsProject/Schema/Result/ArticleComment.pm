package CardsProject::Schema::Result::ArticleComment;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('article_comments');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  body => { data_type => 'text' },
  is_hidden => { data_type => 'boolean', default_value => 0 },
  created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  article_id => { data_type => 'integer', is_nullable => 1 },
  author_id => { data_type => 'integer', is_nullable => 1 },
  parent_comment_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'article',
  'CardsProject::Schema::Result::Article',
  { 'foreign.id' => 'self.article_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'author',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.author_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'parent_comment',
  'CardsProject::Schema::Result::ArticleComment',
  { 'foreign.id' => 'self.parent_comment_id' },
  { on_delete => 'SET NULL', on_update => 'CASCADE' }
);
__PACKAGE__->has_many('replies' => 'CardsProject::Schema::Result::ArticleComment', 'parent_comment_id');

1;
