use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Game list returns 200' => sub {
  $t->get_ok('/api/games')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Game create returns 201' => sub {
  $t->post_ok('/api/games' => json => {
  game_number => 1
  })->status_is(201);
};

subtest 'Game show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/games/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;