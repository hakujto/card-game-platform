package CardsProject::Controller::Cards::CardSet;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('CardSet')->search(
      [     { name => { like => "%${q}%" } },
    { code => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('CardSet')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardSet')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'code', 'release_date', 'rotation_date', 'set_type', 'total_cards', 'is_rotated', 'description', 'logo_url');
  my $entity = $c->schema->resultset('CardSet')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardSet')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'code', 'release_date', 'rotation_date', 'set_type', 'total_cards', 'is_rotated', 'description', 'logo_url');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub is_legal_in_standard ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardSet')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub is_legal_in_format ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardSet')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub card_count_by_rarity ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardSet')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub rotate_out ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('CardSet')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{rotation_date}) && (!(defined $data->{rotation_date} && $data->{rotation_date} gt $data->{release_date}))) {
    push @errors, 'Rotation date must be after release date';
  }
  if ((defined $data->{is_rotated} && $data->{is_rotated} eq 'true') && (!defined $data->{rotation_date})) {
    push @errors, 'Rotated set must have a rotation date';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    name => $entity->name,
    code => $entity->code,
    release_date => $entity->release_date,
    rotation_date => $entity->rotation_date,
    set_type => $entity->set_type,
    total_cards => $entity->total_cards,
    is_rotated => $entity->is_rotated,
    description => $entity->description,
    logo_url => $entity->logo_url
  };
}

1;