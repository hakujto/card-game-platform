package CardsProject::Controller::Content::DraftParticipant;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('DraftParticipant')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftParticipant')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('seat_number', 'joined_at', 'session_id', 'player_id');
  my $entity = $c->schema->resultset('DraftParticipant')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub pick_card ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftParticipant')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub drafted_card_count ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftParticipant')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    seat_number => $entity->seat_number,
    joinedAt => $entity->joined_at,
    session_id => $entity->session_id,
    player_id => $entity->player_id
  };
}

1;