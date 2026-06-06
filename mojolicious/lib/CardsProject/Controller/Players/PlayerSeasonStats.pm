package CardsProject::Controller::Players::PlayerSeasonStats;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('PlayerSeasonStats')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('PlayerSeasonStats')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub win_rate ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('PlayerSeasonStats')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub add_points ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('PlayerSeasonStats')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub record_tournament_win ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('PlayerSeasonStats')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    wins => $entity->wins,
    losses => $entity->losses,
    draws => $entity->draws,
    tournament_wins => $entity->tournament_wins,
    highest_rank => $entity->highest_rank,
    season_points => $entity->season_points,
    player_id => $entity->player_id,
    season_id => $entity->season_id
  };
}

1;