package CardsProject::Controller::Cards::CardAbility;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('CardAbility')->search(
      [     { keyword => { like => "%${q}%" } },
    { ability_text => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('CardAbility')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardAbility')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('ability_type', 'keyword', 'ability_text', 'timing', 'card_id');
  my $entity = $c->schema->resultset('CardAbility')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardAbility')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('ability_type', 'keyword', 'ability_text', 'timing', 'card_id');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub delete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardAbility')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $entity->delete;
  $c->rendered(204);
}

sub is_usable_at ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardAbility')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub describe ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardAbility')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{ability_type} && $data->{ability_type} eq 'Keyword') && (!defined $data->{keyword})) {
    push @errors, 'Keyword ability must have a keyword name';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    ability_type => $entity->ability_type,
    keyword => $entity->keyword,
    ability_text => $entity->ability_text,
    timing => $entity->timing,
    card_id => $entity->card_id
  };
}

1;