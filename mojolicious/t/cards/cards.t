use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'Card list returns 200' => sub {
  $t->get_ok('/api/cards')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'Card search returns 200' => sub {
  $t->get_ok('/api/cards?q=test')
    ->status_is(200);
};

subtest 'Card create returns 201' => sub {
  $t->post_ok('/api/cards' => json => {
  public_id => '00000000-0000-0000-0000-000000000001',
  name => 'Test Lightning Bolt',
  mana_cost => 1,
  mana_colors => 'White',
  description => 'test',
  legal_formats => 'Standard',
  is_banned => 1,
  is_restricted => 1,
  power_level => 3,
  total_copies_in_circulation => 1
  })->status_is(201);
};

subtest 'Card show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/cards/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'Card update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/cards/1' => json => { flavor_text => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;