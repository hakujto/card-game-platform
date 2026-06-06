use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Achievement list returns 200' => sub {
  $t->get_ok('/api/achievements')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Achievement search returns 200' => sub {
  $t->get_ok('/api/achievements?q=test')
    ->status_is(200);
};

subtest 'Achievement create returns 201' => sub {
  $t->post_ok('/api/achievements' => json => {
  name => 'test',
  description => 'test',
  points => 1,
  is_hidden => 1
  })->status_is(201);
};

subtest 'Achievement show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/achievements/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Achievement update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/achievements/1' => json => { name => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;