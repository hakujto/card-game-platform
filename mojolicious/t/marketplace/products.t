use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Product list returns 200' => sub {
  $t->get_ok('/api/products')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Product search returns 200' => sub {
  $t->get_ok('/api/products?q=test')
    ->status_is(200);
};

subtest 'Product create returns 201' => sub {
  $t->post_ok('/api/products' => json => {
  name => 'test',
  price => '0.00',
  stock => 1,
  active => 1,
  discount_percent => 1,
  featured => 1
  })->status_is(201);
};

subtest 'Product show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/products/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Product update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/products/1' => json => { description => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;