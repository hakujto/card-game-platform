package CardsProject::Controller::Content::Article;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('Article')->search(
      [     { title => { like => "%${q}%" } },
    { excerpt => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('Article')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('title', 'slug', 'body', 'excerpt', 'cover_image_url', 'status', 'article_type', 'language', 'view_count', 'likes_count', 'is_featured', 'published_at', 'created_at', 'updated_at', 'author_id', 'featured_deck_id');
  my $entity = $c->schema->resultset('Article')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('title', 'slug', 'body', 'excerpt', 'cover_image_url', 'status', 'article_type', 'language', 'view_count', 'likes_count', 'is_featured', 'published_at', 'created_at', 'updated_at', 'author_id', 'featured_deck_id');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub publish ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub archive ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub increment_view ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub like ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub unlike ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub reading_time_minutes ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub transition_draft_to_published ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Editor', 'Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Draft') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Published' });
  &publish($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_published_to_archived ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Editor', 'Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Published') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Archived' });
  &archive($entity);
  $c->render(json => _to_hash($entity));
}

sub transition_archived_to_draft ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $role = $c->current_user ? $c->current_user->{role} : undef;
  unless (defined $role && grep { $_ eq $role } ('Admin')) {
    return $c->render(status => 403, json => { error => 'Forbidden' });
  }
  if ($entity->status ne 'Archived') {
    return $c->render(status => 409, json => { error => 'Invalid state transition' });
  }
  $entity->update({ status => 'Draft' });
  $c->render(json => _to_hash($entity));
}

sub transition_published_to_draft ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Article')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  return $c->render(status => 409, json => { error => 'Invalid state transition' });
}

sub _validate ($data) {
  my @errors;
  if ((defined $data->{status} && $data->{status} eq 'Published') && (!defined $data->{published_at})) {
    push @errors, 'Published article must have a published_at timestamp';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    title => $entity->title,
    slug => $entity->slug,
    body => $entity->body,
    excerpt => $entity->excerpt,
    cover_image_url => $entity->cover_image_url,
    status => $entity->status,
    article_type => $entity->article_type,
    language => $entity->language,
    view_count => $entity->view_count,
    likes_count => $entity->likes_count,
    is_featured => $entity->is_featured,
    publishedAt => $entity->published_at,
    createdAt => $entity->created_at,
    updatedAt => $entity->updated_at,
    author_id => $entity->author_id,
    featured_deck_id => $entity->featured_deck_id
  };
}

1;