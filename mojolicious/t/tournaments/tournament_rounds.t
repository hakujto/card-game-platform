use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'TournamentRound list returns 200' => sub {
  $t->get_ok('/api/tournament_rounds')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'TournamentRound create returns 201' => sub {
  $t->post_ok('/api/tournament_rounds' => json => {
  round_number => 1,
  time_limit_minutes => 1
  })->status_is(201);
};

subtest 'TournamentRound show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/tournament_rounds/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;