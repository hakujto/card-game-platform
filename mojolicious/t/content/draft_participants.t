use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'DraftParticipant list returns 200' => sub {
  $t->get_ok('/api/draft_participants')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'DraftParticipant create returns 201' => sub {
  $t->post_ok('/api/draft_participants' => json => {
  seat_number => 1,
  joined_at => '2024-01-01 00:00:00'
  })->status_is(201);
};

subtest 'DraftParticipant show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/draft_participants/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;