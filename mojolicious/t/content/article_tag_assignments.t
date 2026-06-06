use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'ArticleTagAssignment list returns 200' => sub {
  $t->get_ok('/api/article_tag_assignments')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'ArticleTagAssignment create returns 201' => sub {
  $t->post_ok('/api/article_tag_assignments' => json => {
  })->status_is(201);
};

subtest 'ArticleTagAssignment show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/article_tag_assignments/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'ArticleTagAssignment delete returns 204 or 404' => sub {
  my $res = $t->delete_ok('/api/article_tag_assignments/1')->tx->res;
  ok($res->code == 204 || $res->code == 404, 'status 204 or 404');
};

done_testing;