package CardsProject::Controller::Content::Stream;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('Stream')->search(
      [     { title => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('Stream')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Stream')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('title', 'stream_url', 'status', 'platform', 'language', 'is_official', 'viewer_count_peak', 'scheduled_start', 'actual_start', 'ended_at', 'vod_url', 'tournament_id', 'streamer_id');
  my $entity = $c->schema->resultset('Stream')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Stream')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('title', 'stream_url', 'status', 'platform', 'language', 'is_official', 'viewer_count_peak', 'scheduled_start', 'actual_start', 'ended_at', 'vod_url', 'tournament_id', 'streamer_id');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub go_live ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Stream')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub end ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Stream')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub update_viewer_peak ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Stream')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub duration_minutes ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Stream')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub transition_scheduled_to_live ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Stream')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Streamer', 'Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Scheduled') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Live' });
  &go_live($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_live_to_ended ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Stream')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Streamer', 'Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Live') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Ended' });
  &end($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_ended_to_live ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Stream')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  return $c->render(status => 409, json => { error => 'Invalid state transition' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{actual_start}) && (!defined $data->{status})) {
    push @errors, 'actual_start_requires_live_or_ended';
  }
  if ((defined $data->{ended_at}) && (!defined $data->{status})) {
    push @errors, 'ended_at can only be set when stream status is Ended';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    title => $entity->title,
    stream_url => $entity->stream_url,
    status => $entity->status,
    platform => $entity->platform,
    language => $entity->language,
    is_official => $entity->is_official,
    viewer_count_peak => $entity->viewer_count_peak,
    scheduledStart => $entity->scheduled_start,
    actualStart => $entity->actual_start,
    endedAt => $entity->ended_at,
    vod_url => $entity->vod_url,
    tournament_id => $entity->tournament_id,
    streamer_id => $entity->streamer_id
  };
}

1;