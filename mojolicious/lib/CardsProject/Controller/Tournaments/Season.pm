package CardsProject::Controller::Tournaments::Season;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('Season')->search(
      [     { name => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('Season')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Season')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'start_date', 'end_date', 'format', 'is_active', 'reward_description');
  my $entity = $c->schema->resultset('Season')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Season')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'start_date', 'end_date', 'format', 'is_active', 'reward_description');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub activate ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Season')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub deactivate ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Season')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub finalize_rewards ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Season')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub is_ongoing ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Season')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    name => $entity->name,
    start_date => $entity->start_date,
    end_date => $entity->end_date,
    format => $entity->format,
    is_active => $entity->is_active,
    reward_description => $entity->reward_description
  };
}

1;