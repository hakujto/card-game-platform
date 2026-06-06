use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'CardRuling list returns 200' => sub {
  $t->get_ok('/api/card_rulings')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'CardRuling create returns 201' => sub {
  $t->post_ok('/api/card_rulings' => json => {
  ruling_text => 'test',
  published_at => '2024-01-01',
  source => 'test'
  })->status_is(201);
};

subtest 'CardRuling show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/card_rulings/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'CardRuling delete returns 204 or 404' => sub {
  my $res = $t->delete_ok('/api/card_rulings/1')->tx->res;
  ok($res->code == 204 || $res->code == 404, 'status 204 or 404');
};

done_testing;