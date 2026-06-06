package CardsProject::Controller::Tournaments::Tournament;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('Tournament')->search(
      [     { name => { like => "%${q}%" } },
    { description => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('Tournament')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'description', 'status', 'format', 'tournament_type', 'max_players', 'entry_fee', 'prize_pool', 'start_time', 'end_time', 'is_online', 'location', 'rules_text', 'created_at', 'season_id', 'organizer_id');
  my $entity = $c->schema->resultset('Tournament')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'description', 'status', 'format', 'tournament_type', 'max_players', 'entry_fee', 'prize_pool', 'start_time', 'end_time', 'is_online', 'location', 'rules_text', 'created_at', 'season_id', 'organizer_id');
  $entity->update(\%cols);
  &sync_season_stats($entity);
  $c->render(json => _to_hash($entity));
}

sub start ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub cancel ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub complete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub generate_round ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub calculate_prize_distribution ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub register_player ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub is_full ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub transition_draft_to_registration ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Draft') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  unless ($c->[object Object]) {
    return $c->render(status => 422, json => { error => 'Transition condition not met' });
  }
  $entity->update({ status => 'Registration' });
  $c->render(json => _to_hash($entity));
}

sub transition_registration_to_ongoing ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Registration') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  unless ($c->[object Object]) {
    return $c->render(status => 422, json => { error => 'Transition condition not met' });
  }
  $entity->update({ status => 'Ongoing' });
  &start($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_registration_to_cancelled ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Registration') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  unless ($c->[object Object]) {
    return $c->render(status => 422, json => { error => 'Transition condition not met' });
  }
  $entity->update({ status => 'Cancelled' });
  &cancel($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_ongoing_to_completed ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Ongoing') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  unless ($c->[object Object]) {
    return $c->render(status => 422, json => { error => 'Transition condition not met' });
  }
  $entity->update({ status => 'Completed' });
  &complete($entity);
  &calculate_prize_distribution($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_ongoing_to_cancelled ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Ongoing') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  unless ($c->[object Object]) {
    return $c->render(status => 422, json => { error => 'Transition condition not met' });
  }
  $entity->update({ status => 'Cancelled' });
  &cancel($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_completed_to_draft ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Completed') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Draft' });
  $c->render(json => _to_hash($entity));
}

sub transition_cancelled_to_draft ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Tournament')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Cancelled') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Draft' });
  $c->render(json => _to_hash($entity));
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{end_time}) && (!(defined $data->{end_time} && $data->{end_time} gt $data->{start_time}))) {
    push @errors, 'End time must be after start time';
  }
  return \@errors;
}

sub sync_season_stats { }

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    name => $entity->name,
    description => $entity->description,
    status => $entity->status,
    format => $entity->format,
    tournament_type => $entity->tournament_type,
    max_players => $entity->max_players,
    entry_fee => $entity->entry_fee,
    prize_pool => $entity->prize_pool,
    startTime => $entity->start_time,
    endTime => $entity->end_time,
    is_online => $entity->is_online,
    location => $entity->location,
    rules_text => $entity->rules_text,
    createdAt => $entity->created_at,
    season_id => $entity->season_id,
    organizer_id => $entity->organizer_id
  };
}

1;