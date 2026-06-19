use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'TournamentRegistration list returns 200' => sub {
  $t->get_ok('/api/tournament_registrations')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'TournamentRegistration create returns 201' => sub {
  $t->post_ok('/api/tournament_registrations' => json => {
  points_earned => 1,
  registered_at => '2024-01-01 00:00:00',
  player_id => 'owner-1'
  })->status_is(201);
};

subtest 'TournamentRegistration show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/tournament_registrations/1' => {'X-User-Id' => 'owner-1'})->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;