package CardsProject::Controller::Marketplace::TradeListing;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('TradeListing')->search(
      [     { description => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('TradeListing')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('status', 'listing_type', 'asking_price', 'auction_start_price', 'auction_current_bid', 'auction_end_time', 'foil', 'condition', 'quantity', 'description', 'created_at', 'expires_at', 'seller_id', 'card_id');
  my $entity = $c->schema->resultset('TradeListing')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('status', 'listing_type', 'asking_price', 'auction_start_price', 'auction_current_bid', 'auction_end_time', 'foil', 'condition', 'quantity', 'description', 'created_at', 'expires_at', 'seller_id', 'card_id');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub close ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub extend ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub cancel ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub is_expired ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub finalize_auction ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

# on status = Sold: finalize_auction
sub _on_finalize_auction ($entity) {
  # triggered when status = Sold
}

sub transition_pending_to_active ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Pending') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  unless ($c->[object Object]) {
    return $c->render(status => 422, json => { error => 'Transition condition not met' });
  }
  $entity->update({ status => 'Active' });
  $c->render(json => _to_hash($entity));
}

sub transition_active_to_sold ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Active') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Sold' });
  &finalize_auction($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_active_to_expired ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Active') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Expired' });
  &close($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_active_to_cancelled ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Active') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  unless ($c->[object Object]) {
    return $c->render(status => 422, json => { error => 'Transition condition not met' });
  }
  $entity->update({ status => 'Cancelled' });
  &cancel($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_sold_to_active ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Sold') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Active' });
  $c->render(json => _to_hash($entity));
}

sub transition_expired_to_active ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeListing')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  if ($entity->status ne 'Expired') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Active' });
  $c->render(json => _to_hash($entity));
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{listing_type} && $data->{listing_type} eq 'FixedPrice') && (!defined $data->{asking_price})) {
    push @errors, 'Fixed price listing must have an asking price';
  }
  if ((defined $data->{listing_type} && $data->{listing_type} eq 'Auction') && (!defined $data->{auction_start_price})) {
    push @errors, 'Auction listing must have a start price and end time';
  }
  if ((defined $data->{listing_type} && $data->{listing_type} eq 'Auction') && (!defined $data->{auction_end_time})) {
    push @errors, 'Auction listing must have a start price and end time';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    status => $entity->status,
    listing_type => $entity->listing_type,
    asking_price => $entity->asking_price,
    auction_start_price => $entity->auction_start_price,
    auction_current_bid => $entity->auction_current_bid,
    auctionEndTime => $entity->auction_end_time,
    foil => $entity->foil,
    condition => $entity->condition,
    quantity => $entity->quantity,
    description => $entity->description,
    createdAt => $entity->created_at,
    expiresAt => $entity->expires_at,
    seller_id => $entity->seller_id,
    card_id => $entity->card_id
  };
}

1;