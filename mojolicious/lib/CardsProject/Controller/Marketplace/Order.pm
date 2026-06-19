package CardsProject::Controller::Marketplace::Order;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('Order')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $uid = $c->req->headers->header('X-User-Id');
  unless (defined $uid && $entity->player_id eq $uid) {
    return $c->render(status => 403, json => { error => 'You do not own this resource.' });
  }
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('status', 'total', 'discount_applied', 'currency', 'payment_method', 'payment_reference', 'shipping_address', 'tracking_number', 'created_at', 'paid_at', 'shipped_at', 'player_id', 'coupon_id');
  &assign_currency_default(\%cols);
  my $entity = $c->schema->resultset('Order')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub cancel ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub pay ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  return $c->render(status => 403, json => { error => 'Forbidden' }) unless $c->param('status');
  $c->render(json => { status => 'ok' });
}

sub process_payment ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub calculate_total ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub apply_discount ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub refund ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

# on status = Shipped: notify_shipped
sub _on_notify_shipped ($entity) {
  # triggered when status = Shipped
}

sub transition_pending_to_paid ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Pending') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Paid' });
  &process_payment($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_paid_to_processing ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Admin', 'Staff')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Paid') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Processing' });
  $c->render(json => _to_hash($entity));
}

sub transition_processing_to_shipped ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Admin', 'Staff')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Processing') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Shipped' });
  &notify_shipped($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_shipped_to_completed ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Admin', 'Staff')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Shipped') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Completed' });
  $c->render(json => _to_hash($entity));
}

sub transition_pending_to_cancelled ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Pending') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Cancelled' });
  &cancel($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_paid_to_cancelled ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Admin', 'Staff')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Paid') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Cancelled' });
  &cancel($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_completed_to_refunded ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Completed') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Refunded' });
  &refund($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_refunded_to_completed ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  return $c->render(status => 409, json => { error => 'Invalid state transition' });
}

sub transition_completed_to_cancelled ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Order')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  return $c->render(status => 409, json => { error => 'Invalid state transition' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{status} && $data->{status} eq 'Paid') && (!defined $data->{paid_at})) {
    push @errors, 'Paid order must have paid_at set';
  }
  if ((defined $data->{status} && $data->{status} eq 'Shipped') && (!defined $data->{tracking_number})) {
    push @errors, 'Shipped order must have a tracking number';
  }
  if ((defined $data->{shipped_at}) && (!defined $data->{status})) {
    push @errors, 'shipped_at_requires_shipped_status';
  }
  return \@errors;
}

sub assign_currency_default { }

sub notify_status_change { }

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    status => $entity->status,
    total => $entity->total,
    discount_applied => $entity->discount_applied,
    currency => $entity->currency,
    payment_method => $entity->payment_method,
    payment_reference => $entity->payment_reference,
    shipping_address => $entity->shipping_address,
    tracking_number => $entity->tracking_number,
    createdAt => $entity->created_at,
    paidAt => $entity->paid_at,
    shippedAt => $entity->shipped_at,
    player_id => $entity->player_id,
    coupon_id => $entity->coupon_id
  };
}

1;