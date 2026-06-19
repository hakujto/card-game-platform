use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Friendship list returns 200' => sub {
  $t->get_ok('/api/friendships')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Friendship create returns 201' => sub {
  $t->post_ok('/api/friendships' => json => {
  requester_id => 'owner-1'
  })->status_is(201);
};

subtest 'Friendship show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/friendships/1' => {'X-User-Id' => 'owner-1'})->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Friendship delete returns 204 or 404' => sub {
  my $res = $t->delete_ok('/api/friendships/1' => {'X-User-Id' => 'owner-1'})->tx->res;
  ok($res->code == 204 || $res->code == 404, 'status 204 or 404');
};

done_testing;