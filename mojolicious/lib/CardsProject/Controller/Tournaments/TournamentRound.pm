package CardsProject::Controller::Tournaments::TournamentRound;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('TournamentRound')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentRound')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('round_number', 'status', 'started_at', 'ended_at', 'time_limit_minutes', 'tournament_id');
  my $entity = $c->schema->resultset('TournamentRound')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub start ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentRound')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub complete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentRound')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub generate_pairings ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentRound')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub is_time_expired ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentRound')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{ended_at}) && (!(defined $data->{ended_at} && $data->{ended_at} gt $data->{started_at}))) {
    push @errors, 'Round end time must be after start time';
  }
  if ((defined $data->{status} && $data->{status} eq 'Completed') && (!defined $data->{started_at})) {
    push @errors, 'Completed round must have a start time';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    round_number => $entity->round_number,
    status => $entity->status,
    startedAt => $entity->started_at,
    endedAt => $entity->ended_at,
    time_limit_minutes => $entity->time_limit_minutes,
    tournament_id => $entity->tournament_id
  };
}

1;