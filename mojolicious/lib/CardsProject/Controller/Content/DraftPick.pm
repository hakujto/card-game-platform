package CardsProject::Controller::Content::DraftPick;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('DraftPick')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftPick')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub is_first_pick ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('DraftPick')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    pick_number => $entity->pick_number,
    pack_number => $entity->pack_number,
    pickedAt => $entity->picked_at,
    participant_id => $entity->participant_id,
    card_id => $entity->card_id
  };
}

1;