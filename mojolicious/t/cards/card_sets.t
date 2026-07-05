use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'CardSet list returns 200' => sub {
  $t->get_ok('/api/card_sets')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'CardSet search returns 200' => sub {
  $t->get_ok('/api/card_sets?q=test')
    ->status_is(200);
};

subtest 'CardSet create returns 201' => sub {
  $t->post_ok('/api/card_sets' => json => {
  name => 'test',
  code => 'ABC',
  release_date => '2024-01-01',
  total_cards => 1,
  is_rotated => 1
  })->status_is(201);
};

subtest 'CardSet show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/card_sets/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'CardSet update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/card_sets/1' => json => { name => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;