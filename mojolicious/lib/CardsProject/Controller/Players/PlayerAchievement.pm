package CardsProject::Controller::Players::PlayerAchievement;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('PlayerAchievement')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('PlayerAchievement')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub increment_progress ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('PlayerAchievement')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub complete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('PlayerAchievement')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

# on is_completed = true: complete
sub _on_complete ($entity) {
  # triggered when is_completed = true
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{is_completed} && $data->{is_completed} eq 'true') && (!(defined $data->{progress} && $data->{progress} gt 0))) {
    push @errors, 'Completed achievement must have progress greater than zero';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    earnedAt => $entity->earned_at,
    progress => $entity->progress,
    is_completed => $entity->is_completed,
    player_id => $entity->player_id,
    achievement_id => $entity->achievement_id
  };
}

1;