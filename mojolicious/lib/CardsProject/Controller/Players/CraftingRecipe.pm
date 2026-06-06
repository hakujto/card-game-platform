package CardsProject::Controller::Players::CraftingRecipe;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('CraftingRecipe')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CraftingRecipe')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('dust_cost', 'is_available', 'result_card_id');
  my $entity = $c->schema->resultset('CraftingRecipe')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CraftingRecipe')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('dust_cost', 'is_available', 'result_card_id');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub can_craft ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CraftingRecipe')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub execute_craft ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CraftingRecipe')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub disable ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CraftingRecipe')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub enable ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CraftingRecipe')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    dust_cost => $entity->dust_cost,
    is_available => $entity->is_available,
    result_card_id => $entity->result_card_id
  };
}

1;