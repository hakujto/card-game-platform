package CardsProject::Schema::Result::Article;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('articles');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  title => { data_type => 'varchar', size => 300 },
  slug => { data_type => 'varchar', size => 300 },
  body => { data_type => 'text' },
  excerpt => { data_type => 'text', is_nullable => 1 },
  cover_image_url => { data_type => 'varchar', is_nullable => 1 },
  status => { data_type => 'varchar', size => 50, default_value => 'Draft' },
  article_type => { data_type => 'varchar', size => 50, default_value => 'Guide' },
  language => { data_type => 'varchar', size => 50, default_value => 'EN' },
  view_count => { data_type => 'integer', default_value => 0 },
  likes_count => { data_type => 'integer', default_value => 0 },
  is_featured => { data_type => 'boolean', default_value => 0 },
  published_at => { data_type => 'datetime', is_nullable => 1 },
  created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  updated_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  author_id => { data_type => 'integer', is_nullable => 1 },
  featured_deck_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'author',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.author_id' }
);
__PACKAGE__->belongs_to(
  'featured_deck',
  'CardsProject::Schema::Result::Deck',
  { 'foreign.id' => 'self.featured_deck_id' }
);
__PACKAGE__->many_to_many('article_tags', 'article_tag_links', 'article_tag');

sub insert_or_update {
  my ($self, @args) = @_;
  my $result = $self->next::method(@args);
  &update_search_index($result);
  return $result;
}

sub update_search_index { }

1;
