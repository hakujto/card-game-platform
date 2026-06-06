use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'CraftingIngredient list returns 200' => sub {
  $t->get_ok('/api/crafting_ingredients')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'CraftingIngredient create returns 201' => sub {
  $t->post_ok('/api/crafting_ingredients' => json => {
  quantity => 1
  })->status_is(201);
};

subtest 'CraftingIngredient show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/crafting_ingredients/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'CraftingIngredient delete returns 204 or 404' => sub {
  my $res = $t->delete_ok('/api/crafting_ingredients/1')->tx->res;
  ok($res->code == 204 || $res->code == 404, 'status 204 or 404');
};

done_testing;