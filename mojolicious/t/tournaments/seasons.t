use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Season list returns 200' => sub {
  $t->get_ok('/api/seasons')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Season search returns 200' => sub {
  $t->get_ok('/api/seasons?q=test')
    ->status_is(200);
};

subtest 'Season create returns 201' => sub {
  $t->post_ok('/api/seasons' => json => {
  name => 'test',
  start_date => '2024-01-01',
  end_date => '2024-01-01',
  is_active => 1
  })->status_is(201);
};

subtest 'Season show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/seasons/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Season update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/seasons/1' => json => { name => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;