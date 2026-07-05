package CardsProject::Controller::Cards::DeckCard;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('DeckCard')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DeckCard')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('quantity', 'is_commander', 'deck_id', 'card_id');
  my $entity = $c->schema->resultset('DeckCard')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DeckCard')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('quantity', 'is_commander', 'deck_id', 'card_id');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub delete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DeckCard')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $entity->delete;
  $c->rendered(204);
}

sub increment ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DeckCard')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub decrement ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DeckCard')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if (defined $data->{quantity} && $data->{quantity} < 1) {
    push @errors, 'quantity must be >= 1';
  }
  if (defined $data->{quantity} && $data->{quantity} > 4) {
    push @errors, 'quantity must be <= 4';
  }
  if ((defined $data->{is_commander} && $data->{is_commander} eq 'true') && (!defined $data->{quantity})) {
    push @errors, 'Commander card must appear exactly once in the deck';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    quantity => $entity->quantity,
    is_commander => $entity->is_commander,
    deck_id => $entity->deck_id,
    card_id => $entity->card_id
  };
}

1;