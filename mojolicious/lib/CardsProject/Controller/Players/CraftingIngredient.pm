package CardsProject::Controller::Players::CraftingIngredient;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('CraftingIngredient')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CraftingIngredient')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('quantity', 'recipe_id', 'card_id');
  my $entity = $c->schema->resultset('CraftingIngredient')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub delete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CraftingIngredient')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $entity->delete;
  $c->rendered(204);
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    quantity => $entity->quantity,
    recipe_id => $entity->recipe_id,
    card_id => $entity->card_id
  };
}

1;