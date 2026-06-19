use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Order list returns 200' => sub {
  $t->get_ok('/api/orders')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Order create returns 201' => sub {
  $t->post_ok('/api/orders' => json => {
  total => '0.00',
  discount_applied => '0.00',
  currency => 'test',
  player_id => 'owner-1'
  })->status_is(201);
};

subtest 'Order show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/orders/1' => {'X-User-Id' => 'owner-1'})->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;