use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'DraftSession list returns 200' => sub {
  $t->get_ok('/api/draft_sessions')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'DraftSession create returns 201' => sub {
  $t->post_ok('/api/draft_sessions' => json => {
  seats => 1,
  time_per_pick_seconds => 1
  })->status_is(201);
};

subtest 'DraftSession show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/draft_sessions/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;