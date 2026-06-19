package CardsProject::Controller::Marketplace::TradeDispute;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('TradeDispute')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeDispute')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('status', 'reason', 'description', 'resolution', 'opened_at', 'resolved_at', 'transaction_id', 'opened_by_id', 'resolved_by_id');
  my $entity = $c->schema->resultset('TradeDispute')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub escalate ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeDispute')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub resolve ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeDispute')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub close_resolved ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeDispute')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub review ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeDispute')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub transition_open_to_under_review ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeDispute')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Admin', 'Moderator')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Open') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'UnderReview' });
  &review($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_under_review_to_resolved ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeDispute')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Admin', 'Moderator')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'UnderReview') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Resolved' });
  &close_resolved($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_under_review_to_escalated ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeDispute')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'UnderReview') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Escalated' });
  &escalate($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_escalated_to_resolved ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeDispute')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Escalated') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Resolved' });
  &close_resolved($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_resolved_to_open ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeDispute')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  return $c->render(status => 409, json => { error => 'Invalid state transition' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{resolved_at}) && (!defined $data->{status})) {
    push @errors, 'resolved_at_requires_terminal_status';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    status => $entity->status,
    reason => $entity->reason,
    description => $entity->description,
    resolution => $entity->resolution,
    openedAt => $entity->opened_at,
    resolvedAt => $entity->resolved_at,
    transaction_id => $entity->transaction_id,
    opened_by_id => $entity->opened_by_id,
    resolved_by_id => $entity->resolved_by_id
  };
}

1;