use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Deck list returns 200' => sub {
  $t->get_ok('/api/decks')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Deck search returns 200' => sub {
  $t->get_ok('/api/decks?q=test')
    ->status_is(200);
};

subtest 'Deck create returns 201' => sub {
  $t->post_ok('/api/decks' => json => {
  name => 'test',
  is_public => 1,
  is_tournament_legal => 1,
  wins => 1,
  losses => 1,
  draws => 1
  })->status_is(201);
};

subtest 'Deck show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/decks/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Deck update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/decks/1' => json => { name => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Deck delete returns 204 or 404' => sub {
  my $res = $t->delete_ok('/api/decks/1')->tx->res;
  ok($res->code == 204 || $res->code == 404, 'status 204 or 404');
};

done_testing;