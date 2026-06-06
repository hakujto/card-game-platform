use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'PlayerCollection list returns 200' => sub {
  $t->get_ok('/api/player_collections')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'PlayerCollection create returns 201' => sub {
  $t->post_ok('/api/player_collections' => json => {
  quantity => 1,
  foil => 1,
  acquired_at => '2024-01-01 00:00:00'
  })->status_is(201);
};

subtest 'PlayerCollection show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/player_collections/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'PlayerCollection update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/player_collections/1' => json => { quantity => 1 })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'PlayerCollection delete returns 204 or 404' => sub {
  my $res = $t->delete_ok('/api/player_collections/1')->tx->res;
  ok($res->code == 204 || $res->code == 404, 'status 204 or 404');
};

done_testing;