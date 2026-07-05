package CardsProject::Controller::Cards::Deck;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('Deck')->search(
      [     { name => { like => "%${q}%" } },
    { description => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('Deck')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Deck')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'description', 'format', 'is_public', 'is_tournament_legal', 'archetype', 'wins', 'losses', 'draws', 'created_at', 'updated_at', 'player_id');
  my $entity = $c->schema->resultset('Deck')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Deck')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'description', 'format', 'is_public', 'is_tournament_legal', 'archetype', 'updated_at', 'player_id');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub delete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Deck')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $entity->delete;
  $c->rendered(204);
}

sub validate_size ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Deck')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub add_card ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Deck')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub remove_card ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Deck')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub win_rate ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Deck')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub clone ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Deck')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub publish ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Deck')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub unpublish ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Deck')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub certify_tournament_legal ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Deck')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{is_tournament_legal} && $data->{is_tournament_legal} eq 'true') && (!defined $data->{is_public})) {
    push @errors, 'Tournament-legal deck must be made public';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    name => $entity->name,
    description => $entity->description,
    format => $entity->format,
    is_public => $entity->is_public,
    is_tournament_legal => $entity->is_tournament_legal,
    archetype => $entity->archetype,
    wins => $entity->wins,
    losses => $entity->losses,
    draws => $entity->draws,
    createdAt => $entity->created_at,
    updatedAt => $entity->updated_at,
    player_id => $entity->player_id
  };
}

1;