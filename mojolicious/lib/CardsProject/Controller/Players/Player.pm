package CardsProject::Controller::Players::Player;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('Player')->search(
      [     { display_name => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('Player')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Player')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('public_id', 'display_name', 'rank', 'rating', 'peak_rating', 'bio', 'country_code', 'avatar_url', 'preferred_format', 'contact_email', 'win_rate_cached', 'is_verified', 'created_at', 'last_active_at', 'user_id');
  my $entity = $c->schema->resultset('Player')->create(\%cols);
  &initialize_collection($entity);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Player')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('public_id', 'display_name', 'rank', 'bio', 'country_code', 'avatar_url', 'preferred_format', 'contact_email', 'win_rate_cached', 'is_verified', 'last_active_at', 'user_id');
  $entity->update(\%cols);
  &update_rank($entity);
  $c->render(json => _to_hash($entity));
}

sub promote ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Player')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub demote ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Player')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub record_win ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Player')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub record_loss ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Player')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub win_rate ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Player')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub verify ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Player')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub update_rating ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Player')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if (defined $data->{country_code} && $data->{country_code} !~ /[A-Z]{2}/) {
    push @errors, 'country_code does not match required pattern';
  }
  return \@errors;
}

sub initialize_collection { }

sub update_rank { }

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    public_id => $entity->public_id,
    display_name => $entity->display_name,
    rank => $entity->rank,
    rating => $entity->rating,
    peak_rating => $entity->peak_rating,
    bio => $entity->bio,
    country_code => $entity->country_code,
    avatar_url => $entity->avatar_url,
    preferred_format => $entity->preferred_format,
    contact_email => $entity->contact_email,
    win_rate_cached => $entity->win_rate_cached,
    is_verified => $entity->is_verified,
    createdAt => $entity->created_at,
    lastActiveAt => $entity->last_active_at,
    user_id => $entity->user_id
  };
}

1;