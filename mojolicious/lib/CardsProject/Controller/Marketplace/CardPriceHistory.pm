package CardsProject::Controller::Marketplace::CardPriceHistory;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('CardPriceHistory')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardPriceHistory')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub price_change_percent ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardPriceHistory')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub is_price_spike ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardPriceHistory')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    price_date => $entity->price_date,
    avg_price => $entity->avg_price,
    min_price => $entity->min_price,
    max_price => $entity->max_price,
    volume => $entity->volume,
    foil => $entity->foil,
    card_id => $entity->card_id
  };
}

1;