use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'PlayerAchievement list returns 200' => sub {
  $t->get_ok('/api/player_achievements')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'PlayerAchievement show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/player_achievements/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;