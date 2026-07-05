use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Article list returns 200' => sub {
  $t->get_ok('/api/articles')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Article search returns 200' => sub {
  $t->get_ok('/api/articles?q=test')
    ->status_is(200);
};

subtest 'Article create returns 201' => sub {
  $t->post_ok('/api/articles' => json => {
  title => 'test',
  slug => 'test',
  body => 'test',
  view_count => 1,
  likes_count => 1,
  total_views_alltime => 1,
  is_featured => 1
  })->status_is(201);
};

subtest 'Article show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/articles/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Article update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/articles/1' => json => { excerpt => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;