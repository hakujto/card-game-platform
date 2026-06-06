use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Stream list returns 200' => sub {
  $t->get_ok('/api/streams')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Stream search returns 200' => sub {
  $t->get_ok('/api/streams?q=test')
    ->status_is(200);
};

subtest 'Stream create returns 201' => sub {
  $t->post_ok('/api/streams' => json => {
  title => 'test',
  stream_url => 'https://example.com',
  is_official => 1,
  viewer_count_peak => 1,
  scheduled_start => '2024-01-01 00:00:00'
  })->status_is(201);
};

subtest 'Stream show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/streams/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Stream update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/streams/1' => json => { title => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;