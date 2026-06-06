package CardsProject::Controller::Tournaments::AwardedPrize;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('AwardedPrize')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('AwardedPrize')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub claim ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('AwardedPrize')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

# on claimed = true: claim
sub _on_claim ($entity) {
  # triggered when claimed = true
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{claimed} && $data->{claimed} eq 'true') && (!defined $data->{claimed_at})) {
    push @errors, 'Claimed prize must have a claimed_at timestamp';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    final_placement => $entity->final_placement,
    awardedAt => $entity->awarded_at,
    claimed => $entity->claimed,
    claimedAt => $entity->claimed_at,
    prize_id => $entity->prize_id,
    player_id => $entity->player_id
  };
}

1;