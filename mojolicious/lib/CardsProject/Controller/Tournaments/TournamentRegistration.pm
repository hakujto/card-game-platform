package CardsProject::Controller::Tournaments::TournamentRegistration;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('TournamentRegistration')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentRegistration')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('status', 'seed', 'final_standing', 'points_earned', 'registered_at', 'tournament_id', 'player_id', 'deck_id');
  my $entity = $c->schema->resultset('TournamentRegistration')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub withdraw ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentRegistration')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub disqualify ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentRegistration')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub promote_from_waitlist ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentRegistration')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{final_standing}) && (!(defined $data->{final_standing} && $data->{final_standing} gt 0))) {
    push @errors, 'Final standing must be greater than zero';
  }
  if ((defined $data->{seed}) && (!(defined $data->{seed} && $data->{seed} gt 0))) {
    push @errors, 'Seed must be greater than zero';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    status => $entity->status,
    seed => $entity->seed,
    final_standing => $entity->final_standing,
    points_earned => $entity->points_earned,
    registeredAt => $entity->registered_at,
    tournament_id => $entity->tournament_id,
    player_id => $entity->player_id,
    deck_id => $entity->deck_id
  };
}

1;