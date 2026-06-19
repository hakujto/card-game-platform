package CardsProject::Controller::Tournaments::Match;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('Match')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('table_number', 'status', 'player1_wins', 'player2_wins', 'started_at', 'ended_at', 'result_notes', 'round_id', 'player1_id', 'player2_id');
  my $entity = $c->schema->resultset('Match')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub record_result ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
  &determine_winner($entity);
}

sub finalize_result ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
  &determine_winner($entity);
}

sub determine_winner ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub concede ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  return $c->render(status => 403, json => { error => 'Forbidden' }) unless $c->param('status');
  $c->render(json => { status => 'ok' });
}

sub draw ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub transition_pending_to_active ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Judge', 'HeadJudge', 'Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Pending') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Active' });
  $c->render(json => _to_hash($entity));
}

sub transition_active_to_completed ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Judge', 'HeadJudge', 'Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Active') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Completed' });
  &finalize_result($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_active_to_draw ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Judge', 'HeadJudge', 'Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Active') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Draw' });
  &draw($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_pending_to_b_y_e ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Judge', 'HeadJudge', 'Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Pending') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'BYE' });
  $c->render(json => _to_hash($entity));
}

sub transition_completed_to_active ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  return $c->render(status => 409, json => { error => 'Invalid state transition' });
}

sub transition_draw_to_active ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  return $c->render(status => 409, json => { error => 'Invalid state transition' });
}

sub transition_b_y_e_to_active ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Match')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  return $c->render(status => 409, json => { error => 'Invalid state transition' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{status} && $data->{status} eq 'BYE') && (defined $data->{player2})) {
    push @errors, 'BYE match must not have a second player';
  }
  if ((defined $data->{ended_at}) && (!(defined $data->{ended_at} && $data->{ended_at} gt $data->{started_at}))) {
    push @errors, 'Match end time must be after start time';
  }
  if ((defined $data->{status} && $data->{status} eq 'Completed') && (!defined $data->{started_at})) {
    push @errors, 'Completed match must have a start time';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    table_number => $entity->table_number,
    status => $entity->status,
    player1_wins => $entity->player1_wins,
    player2_wins => $entity->player2_wins,
    startedAt => $entity->started_at,
    endedAt => $entity->ended_at,
    result_notes => $entity->result_notes,
    round_id => $entity->round_id,
    player1_id => $entity->player1_id,
    player2_id => $entity->player2_id
  };
}

1;