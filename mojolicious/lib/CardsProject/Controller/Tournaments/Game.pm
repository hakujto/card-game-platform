package CardsProject::Controller::Tournaments::Game;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('Game')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Game')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('game_number', 'winner_side', 'turns_played', 'duration_seconds', 'ended_by', 'replay_url', 'match_id', 'winner_id');
  my $entity = $c->schema->resultset('Game')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub record_winner ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Game')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub duration_minutes ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Game')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{turns_played}) && (!(defined $data->{turns_played} && $data->{turns_played} gt 0))) {
    push @errors, 'Turns played must be greater than zero';
  }
  if ((defined $data->{duration_seconds}) && (!(defined $data->{duration_seconds} && $data->{duration_seconds} gt 0))) {
    push @errors, 'Game duration must be greater than zero';
  }
  if ((defined $data->{winner_side} && $data->{winner_side} eq 'Draw') && (defined $data->{winner})) {
    push @errors, 'A draw cannot have a winner';
  }
  if ((defined $data->{undefined}) && (!defined $data->{winner})) {
    push @errors, 'A decisive game must have a winner player set';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    game_number => $entity->game_number,
    winner_side => $entity->winner_side,
    turns_played => $entity->turns_played,
    duration_seconds => $entity->duration_seconds,
    ended_by => $entity->ended_by,
    replay_url => $entity->replay_url,
    match_id => $entity->match_id,
    winner_id => $entity->winner_id
  };
}

1;