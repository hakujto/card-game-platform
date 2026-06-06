use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

BEGIN { $ENV{TEST_DATABASE_URL} = 'dbi:SQLite::memory:' }

my $t = Test::Mojo->new('CardsProject');

subtest 'CraftingRecipe list returns 200' => sub {
  $t->get_ok('/api/crafting_recipes')
    ->status_is(200)
    ->json_is('', []);
};

subtest 'CraftingRecipe create returns 201' => sub {
  $t->post_ok('/api/crafting_recipes' => json => {
  dust_cost => 1,
  is_available => 1
  })->status_is(201);
};

subtest 'CraftingRecipe show returns 200 or 404' => sub {
  my $res = $t->get_ok('/api/crafting_recipes/1')->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

subtest 'CraftingRecipe update returns 200 or 404' => sub {
  my $res = $t->patch_ok('/api/crafting_recipes/1' => json => { dust_cost => 1 })->tx->res;
  ok($res->code == 200 || $res->code == 404, 'status 200 or 404');
};

done_testing;