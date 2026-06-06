package CardsProject::Controller::Cards::CardRuling;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('CardRuling')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardRuling')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('ruling_text', 'published_at', 'source', 'card_id');
  my $entity = $c->schema->resultset('CardRuling')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub delete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardRuling')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $entity->delete;
  $c->rendered(204);
}

sub is_current ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardRuling')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub supersedes_previous ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardRuling')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    ruling_text => $entity->ruling_text,
    published_at => $entity->published_at,
    source => $entity->source,
    card_id => $entity->card_id
  };
}

1;