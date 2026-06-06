package CardsProject::Controller::Tournaments::TournamentPrize;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('TournamentPrize')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentPrize')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('placement_from', 'placement_to', 'prize_type', 'amount', 'description', 'packs_count', 'season_points', 'tournament_id');
  my $entity = $c->schema->resultset('TournamentPrize')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentPrize')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('placement_from', 'placement_to', 'prize_type', 'amount', 'description', 'packs_count', 'season_points', 'tournament_id');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub delete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentPrize')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $entity->delete;
  $c->rendered(204);
}

sub applies_to_placement ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentPrize')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub award_to_player ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentPrize')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    placement_from => $entity->placement_from,
    placement_to => $entity->placement_to,
    prize_type => $entity->prize_type,
    amount => $entity->amount,
    description => $entity->description,
    packs_count => $entity->packs_count,
    season_points => $entity->season_points,
    tournament_id => $entity->tournament_id
  };
}

1;