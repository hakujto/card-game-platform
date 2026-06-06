package CardsProject::Controller::Content::DraftSession;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('DraftSession')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftSession')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('status', 'draft_type', 'seats', 'time_per_pick_seconds', 'created_at', 'completed_at', 'card_set_id');
  my $entity = $c->schema->resultset('DraftSession')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub start ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftSession')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub abandon ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftSession')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub complete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftSession')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub is_full ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftSession')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub transition_waiting_for_players_to_drafting ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftSession')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'WaitingForPlayers') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Drafting' });
  &start($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_drafting_to_completed ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftSession')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Drafting') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Completed' });
  &complete($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_drafting_to_abandoned ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftSession')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Drafting') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  unless ($c->[object Object]) {
    return $c->render(status => 422, json => { error => 'Transition condition not met' });
  }
  $entity->update({ status => 'Abandoned' });
  &abandon($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_waiting_for_players_to_abandoned ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftSession')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'WaitingForPlayers') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  unless ($c->[object Object]) {
    return $c->render(status => 422, json => { error => 'Transition condition not met' });
  }
  $entity->update({ status => 'Abandoned' });
  &abandon($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_completed_to_drafting ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftSession')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Completed') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Drafting' });
  $c->render(json => _to_hash($entity));
}

sub transition_abandoned_to_drafting ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftSession')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Abandoned') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Drafting' });
  $c->render(json => _to_hash($entity));
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{completed_at}) && (!defined $data->{status})) {
    push @errors, 'completed_at can only be set when draft status is Completed';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    status => $entity->status,
    draft_type => $entity->draft_type,
    seats => $entity->seats,
    time_per_pick_seconds => $entity->time_per_pick_seconds,
    createdAt => $entity->created_at,
    completedAt => $entity->completed_at,
    card_set_id => $entity->card_set_id
  };
}

1;