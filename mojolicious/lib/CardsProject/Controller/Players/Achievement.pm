package CardsProject::Controller::Players::Achievement;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('Achievement')->search(
      [     { name => { like => "%${q}%" } },
    { description => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('Achievement')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Achievement')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'description', 'icon_url', 'points', 'rarity', 'is_hidden');
  my $entity = $c->schema->resultset('Achievement')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Achievement')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'description', 'icon_url', 'points', 'rarity', 'is_hidden');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub point_value ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Achievement')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub reveal ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Achievement')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    name => $entity->name,
    description => $entity->description,
    icon_url => $entity->icon_url,
    points => $entity->points,
    rarity => $entity->rarity,
    is_hidden => $entity->is_hidden
  };
}

1;