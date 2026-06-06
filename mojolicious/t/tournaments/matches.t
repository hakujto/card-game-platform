use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Match list returns 200' => sub {
  $t->get_ok('/api/matches')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Match create returns 201' => sub {
  $t->post_ok('/api/matches' => json => {
  player1_wins => 1,
  player2_wins => 1
  })->status_is(201);
};

subtest 'Match show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/matches/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;