use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'DeckTag list returns 200' => sub {
  $t->get_ok('/api/deck_tags')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'DeckTag search returns 200' => sub {
  $t->get_ok('/api/deck_tags?q=test')
    ->status_is(200);
};

subtest 'DeckTag create returns 201' => sub {
  $t->post_ok('/api/deck_tags' => json => {
  name => 'test'
  })->status_is(201);
};

subtest 'DeckTag show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/deck_tags/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'DeckTag update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/deck_tags/1' => json => { name => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'DeckTag delete returns 204 or 404' => sub {
  my $res = $t->delete_ok('/api/deck_tags/1')->tx->res;
  ok($res->code == 204 || $res->code == 404, 'status 204 or 404');
};

done_testing;