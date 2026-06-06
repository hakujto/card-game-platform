package CardsProject::Controller::Marketplace::OrderItem;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('OrderItem')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('OrderItem')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('quantity', 'price_at_purchase', 'foil', 'order_id', 'product_id');
  my $entity = $c->schema->resultset('OrderItem')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub delete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('OrderItem')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $entity->delete;
  $c->rendered(204);
}

sub line_total ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('OrderItem')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    quantity => $entity->quantity,
    price_at_purchase => $entity->price_at_purchase,
    foil => $entity->foil,
    order_id => $entity->order_id,
    product_id => $entity->product_id
  };
}

1;