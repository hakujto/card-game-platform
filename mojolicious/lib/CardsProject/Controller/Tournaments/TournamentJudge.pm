package CardsProject::Controller::Tournaments::TournamentJudge;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('TournamentJudge')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentJudge')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('role', 'tournament_id', 'player_id');
  my $entity = $c->schema->resultset('TournamentJudge')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub delete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentJudge')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $entity->delete;
  $c->rendered(204);
}

sub promote_to_head ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentJudge')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub remove ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('TournamentJudge')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    role => $entity->role,
    tournament_id => $entity->tournament_id,
    player_id => $entity->player_id
  };
}

1;