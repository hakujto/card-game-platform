package CardsProject::Controller::Cards::Card;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('Card')->search(
      [     { name => { like => "%${q}%" } },
    { artist_name => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('Card')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Card')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'card_type', 'rarity', 'mana_cost', 'mana_colors', 'attack', 'defense', 'loyalty', 'description', 'flavor_text', 'image_url', 'artist_name', 'legal_formats', 'is_banned', 'is_restricted', 'power_level', 'set_id');
  my $entity = $c->schema->resultset('Card')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Card')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'card_type', 'rarity', 'mana_cost', 'mana_colors', 'attack', 'defense', 'loyalty', 'description', 'flavor_text', 'image_url', 'artist_name', 'legal_formats', 'is_banned', 'is_restricted', 'power_level', 'set_id');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub ban ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Card')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub unban ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Card')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub restrict ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Card')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub unrestrict ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Card')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub calculate_value ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Card')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub apply_rarity_bonus ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Card')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub is_legal_in_format ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Card')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{card_type} && $data->{card_type} eq 'Creature') && (!defined $data->{attack})) {
    push @errors, 'Creature card must have attack and defense';
  }
  if ((defined $data->{card_type} && $data->{card_type} eq 'Creature') && (!defined $data->{defense})) {
    push @errors, 'Creature card must have attack and defense';
  }
  if ((defined $data->{card_type} && $data->{card_type} eq 'Planeswalker') && (!defined $data->{loyalty})) {
    push @errors, 'Planeswalker card must have loyalty';
  }
  if ((defined $data->{card_type} && $data->{card_type} eq 'Land') && (!defined $data->{mana_cost})) {
    push @errors, 'Land card must have zero mana cost';
  }
  if ((defined $data->{card_type}) && (defined $data->{loyalty})) {
    push @errors, 'Only Planeswalker cards can have loyalty';
  }
  if ((defined $data->{is_banned} && $data->{is_banned} eq 'true') && (!defined $data->{legal_formats})) {
    push @errors, 'banned_card_not_in_legal_formats';
  }
  return \@errors;
}

sub validate_not_in_use { }

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    name => $entity->name,
    card_type => $entity->card_type,
    rarity => $entity->rarity,
    mana_cost => $entity->mana_cost,
    mana_colors => $entity->mana_colors,
    attack => $entity->attack,
    defense => $entity->defense,
    loyalty => $entity->loyalty,
    description => $entity->description,
    flavor_text => $entity->flavor_text,
    image_url => $entity->image_url,
    artist_name => $entity->artist_name,
    legal_formats => $entity->legal_formats,
    is_banned => $entity->is_banned,
    is_restricted => $entity->is_restricted,
    power_level => $entity->power_level,
    set_id => $entity->set_id
  };
}

1;