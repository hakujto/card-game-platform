use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Tournament list returns 200' => sub {
  $t->get_ok('/api/tournaments')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Tournament search returns 200' => sub {
  $t->get_ok('/api/tournaments?q=test')
    ->status_is(200);
};

subtest 'Tournament create returns 201' => sub {
  $t->post_ok('/api/tournaments' => json => {
  name => 'test',
  max_players => 1,
  entry_fee => '0.00',
  prize_pool => '0.00',
  start_time => '2024-01-01 00:00:00',
  is_online => 1
  })->status_is(201);
};

subtest 'Tournament show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/tournaments/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Tournament update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/tournaments/1' => json => { name => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;