use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'ArticleTag list returns 200' => sub {
  $t->get_ok('/api/article_tags')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'ArticleTag search returns 200' => sub {
  $t->get_ok('/api/article_tags?q=test')
    ->status_is(200);
};

subtest 'ArticleTag create returns 201' => sub {
  $t->post_ok('/api/article_tags' => json => {
  name => 'test',
  slug => 'test'
  })->status_is(201);
};

subtest 'ArticleTag show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/article_tags/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'ArticleTag update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/article_tags/1' => json => { name => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'ArticleTag delete returns 204 or 404' => sub {
  my $res = $t->delete_ok('/api/article_tags/1')->tx->res;
  ok($res->code == 204 || $res->code == 404, 'status 204 or 404');
};

done_testing;