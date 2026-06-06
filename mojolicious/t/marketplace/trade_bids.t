use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'TradeBid list returns 200' => sub {
  $t->get_ok('/api/trade_bids')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'TradeBid create returns 201' => sub {
  $t->post_ok('/api/trade_bids' => json => {
  amount => '0.00',
  placed_at => '2024-01-01 00:00:00',
  is_winning => 1
  })->status_is(201);
};

subtest 'TradeBid show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/trade_bids/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;