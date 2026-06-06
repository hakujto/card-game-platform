use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Player list returns 200' => sub {
  $t->get_ok('/api/players')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Player search returns 200' => sub {
  $t->get_ok('/api/players?q=test')
    ->status_is(200);
};

subtest 'Player create returns 201' => sub {
  $t->post_ok('/api/players' => json => {
  display_name => 'test',
  rating => 1,
  peak_rating => 1,
  is_verified => 1
  })->status_is(201);
};

subtest 'Player show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/players/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Player update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/players/1' => json => { display_name => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;