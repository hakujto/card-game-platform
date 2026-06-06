use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'DeckCard list returns 200' => sub {
  $t->get_ok('/api/deck_cards')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'DeckCard create returns 201' => sub {
  $t->post_ok('/api/deck_cards' => json => {
  quantity => 1,
  is_commander => 1
  })->status_is(201);
};

subtest 'DeckCard show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/deck_cards/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'DeckCard update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/deck_cards/1' => json => { quantity => 1 })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'DeckCard delete returns 204 or 404' => sub {
  my $res = $t->delete_ok('/api/deck_cards/1')->tx->res;
  ok($res->code == 204 || $res->code == 404, 'status 204 or 404');
};

done_testing;