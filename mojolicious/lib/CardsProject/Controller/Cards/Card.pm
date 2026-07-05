package CardsProject::Controller::Cards::Card;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::JSON qw(encode_json decode_json);

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
  $data->{created_by} = $c->current_user->{id} if $c->current_user;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('public_id', 'name', 'card_type', 'rarity', 'mana_cost', 'mana_colors', 'attack', 'defense', 'loyalty', 'description', 'flavor_text', 'image_url', 'artist_name', 'legal_formats', 'is_banned', 'is_restricted', 'power_level', 'metadata', 'total_copies_in_circulation', 'set_id');
  $cols{metadata} = encode_json($cols{metadata}) if exists $cols{metadata};
  my $entity = $c->schema->resultset('Card')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Card')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  $data->{updated_by} = $c->current_user->{id} if $c->current_user;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('public_id', 'name', 'card_type', 'rarity', 'mana_cost', 'mana_colors', 'attack', 'defense', 'loyalty', 'description', 'flavor_text', 'image_url', 'artist_name', 'legal_formats', 'power_level', 'metadata', 'total_copies_in_circulation', 'set_id');
  $cols{metadata} = encode_json($cols{metadata}) if exists $cols{metadata};
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

sub replace ($c) {
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
  if (defined $data->{mana_cost} && $data->{mana_cost} < 0) {
    push @errors, 'mana_cost must be >= 0';
  }
  if (defined $data->{mana_cost} && $data->{mana_cost} > 20) {
    push @errors, 'mana_cost must be <= 20';
  }
  if (defined $data->{power_level} && $data->{power_level} < 1) {
    push @errors, 'power_level must be >= 1';
  }
  if (defined $data->{power_level} && $data->{power_level} > 10) {
    push @errors, 'power_level must be <= 10';
  }
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
    public_id => $entity->public_id,
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
    metadata => (defined $entity->metadata ? decode_json($entity->metadata) : undef),
    total_copies_in_circulation => $entity->total_copies_in_circulation,
    set_id => $entity->set_id
  };
}

1;