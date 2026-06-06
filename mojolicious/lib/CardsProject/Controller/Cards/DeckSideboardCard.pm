package CardsProject::Controller::Cards::DeckSideboardCard;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('DeckSideboardCard')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DeckSideboardCard')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('quantity', 'deck_id', 'card_id');
  my $entity = $c->schema->resultset('DeckSideboardCard')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DeckSideboardCard')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('quantity', 'deck_id', 'card_id');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub delete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DeckSideboardCard')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $entity->delete;
  $c->rendered(204);
}

sub increment ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DeckSideboardCard')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub decrement ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DeckSideboardCard')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    quantity => $entity->quantity,
    deck_id => $entity->deck_id,
    card_id => $entity->card_id
  };
}

1;