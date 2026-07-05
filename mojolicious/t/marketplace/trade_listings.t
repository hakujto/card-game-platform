use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'TradeListing list returns 200' => sub {
  $t->get_ok('/api/trade_listings')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'TradeListing search returns 200' => sub {
  $t->get_ok('/api/trade_listings?q=test')
    ->status_is(200);
};

subtest 'TradeListing create returns 201' => sub {
  $t->post_ok('/api/trade_listings' => json => {
  public_id => '00000000-0000-0000-0000-000000000001',
  foil => 1,
  quantity => 1
  })->status_is(201);
};

subtest 'TradeListing show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/trade_listings/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'TradeListing update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/trade_listings/1' => json => { public_id => '00000000-0000-0000-0000-000000000001' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;