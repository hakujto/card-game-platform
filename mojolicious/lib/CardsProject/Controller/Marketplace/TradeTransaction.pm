package CardsProject::Controller::Marketplace::TradeTransaction;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('TradeTransaction')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeTransaction')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub complete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeTransaction')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub refund ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeTransaction')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub open_dispute ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeTransaction')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub seller_net ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeTransaction')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{status} && $data->{status} eq 'Completed') && (!defined $data->{completed_at})) {
    push @errors, 'Completed transaction must have a completed_at timestamp';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    final_price => $entity->final_price,
    platform_fee => $entity->platform_fee,
    status => $entity->status,
    completedAt => $entity->completed_at,
    listing_id => $entity->listing_id,
    buyer_id => $entity->buyer_id,
    seller_id => $entity->seller_id
  };
}

1;