use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'CardAbility list returns 200' => sub {
  $t->get_ok('/api/card_abilities')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'CardAbility search returns 200' => sub {
  $t->get_ok('/api/card_abilities?q=test')
    ->status_is(200);
};

subtest 'CardAbility create returns 201' => sub {
  $t->post_ok('/api/card_abilities' => json => {
  ability_text => 'test'
  })->status_is(201);
};

subtest 'CardAbility show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/card_abilities/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'CardAbility update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/card_abilities/1' => json => { keyword => 'test' })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'CardAbility delete returns 204 or 404' => sub {
  my $res = $t->delete_ok('/api/card_abilities/1')->tx->res;
  ok($res->code == 204 || $res->code == 404, 'status 204 or 404');
};

done_testing;