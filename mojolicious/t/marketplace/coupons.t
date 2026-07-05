use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Coupon list returns 200' => sub {
  $t->get_ok('/api/coupons')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Coupon search returns 200' => sub {
  $t->get_ok('/api/coupons?q=test')
    ->status_is(200);
};

subtest 'Coupon create returns 201' => sub {
  $t->post_ok('/api/coupons' => json => {
  code => 'test',
  discount_value => 0.01,
  min_order_value => '0.00',
  valid_from => '2024-01-01 00:00:00',
  valid_until => '2024-01-01 00:00:00',
  is_active => 1
  })->status_is(201);
};

subtest 'Coupon show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/coupons/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Coupon update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/coupons/1' => json => { code => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;