package CardsProject::Controller::Players::Friendship;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('Friendship')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Friendship')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('status', 'created_at', 'requester_id', 'receiver_id');
  my $entity = $c->schema->resultset('Friendship')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub delete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Friendship')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $entity->delete;
  $c->rendered(204);
}

sub accept ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Friendship')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub decline ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Friendship')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub block ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Friendship')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    status => $entity->status,
    createdAt => $entity->created_at,
    requester_id => $entity->requester_id,
    receiver_id => $entity->receiver_id
  };
}

1;