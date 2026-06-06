use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'TournamentPrize list returns 200' => sub {
  $t->get_ok('/api/tournament_prizes')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'TournamentPrize create returns 201' => sub {
  $t->post_ok('/api/tournament_prizes' => json => {
  placement_from => 1,
  placement_to => 1,
  prize_type => 'Currency',
  amount => '0.00',
  season_points => 1
  })->status_is(201);
};

subtest 'TournamentPrize show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/tournament_prizes/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'TournamentPrize update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/tournament_prizes/1' => json => { placement_from => 1 })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'TournamentPrize delete returns 204 or 404' => sub {
  my $res = $t->delete_ok('/api/tournament_prizes/1')->tx->res;
  ok($res->code == 204 || $res->code == 404, 'status 204 or 404');
};

done_testing;