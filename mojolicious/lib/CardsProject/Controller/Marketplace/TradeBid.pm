package CardsProject::Controller::Marketplace::TradeBid;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('TradeBid')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeBid')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('amount', 'placed_at', 'is_winning', 'listing_id', 'bidder_id');
  my $entity = $c->schema->resultset('TradeBid')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub outbid_by ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeBid')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub retract ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TradeBid')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    amount => $entity->amount,
    placedAt => $entity->placed_at,
    is_winning => $entity->is_winning,
    listing_id => $entity->listing_id,
    bidder_id => $entity->bidder_id
  };
}

1;