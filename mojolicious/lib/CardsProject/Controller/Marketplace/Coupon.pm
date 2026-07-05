package CardsProject::Controller::Marketplace::Coupon;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('Coupon')->search(
      [     { code => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('Coupon')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Coupon')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('code', 'discount_type', 'discount_value', 'min_order_value', 'max_uses', 'uses_count', 'valid_from', 'valid_until', 'is_active');
  my $entity = $c->schema->resultset('Coupon')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Coupon')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('code', 'discount_type', 'discount_value', 'min_order_value', 'max_uses', 'uses_count', 'valid_from', 'valid_until', 'is_active');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub is_valid ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Coupon')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub is_applicable_to_order ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Coupon')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub redeem ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Coupon')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  return $c->render(status => 403, json => { error => 'Forbidden' }) unless $c->param('is_active');
  $c->render(json => { status => 'ok' });
}

sub deactivate ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Coupon')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if (defined $data->{discount_value} && $data->{discount_value} < 0.01) {
    push @errors, 'discount_value must be >= 0.01';
  }
  if ((defined $data->{discount_type} && $data->{discount_type} eq 'Percent') && (!defined $data->{discount_value})) {
    push @errors, 'Percent discount must be between 1 and 100';
  }
  if ((defined $data->{max_uses}) && (!defined $data->{uses_count})) {
    push @errors, 'Coupon uses count cannot exceed max_uses';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    code => $entity->code,
    discount_type => $entity->discount_type,
    discount_value => $entity->discount_value,
    min_order_value => $entity->min_order_value,
    valid_from => $entity->valid_from,
    valid_until => $entity->valid_until,
    is_active => $entity->is_active
  };
}

1;