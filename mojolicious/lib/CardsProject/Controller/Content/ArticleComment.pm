package CardsProject::Controller::Content::ArticleComment;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my @items = $c->schema->resultset('ArticleComment')->all;
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('ArticleComment')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('body', 'is_hidden', 'created_at', 'article_id', 'author_id', 'parent_comment_id');
  my $entity = $c->schema->resultset('ArticleComment')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub delete ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('ArticleComment')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $entity->delete;
  $c->rendered(204);
}

sub hide ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('ArticleComment')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub unhide ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('ArticleComment')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub is_reply ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('ArticleComment')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    body => $entity->body,
    is_hidden => $entity->is_hidden,
    createdAt => $entity->created_at,
    article_id => $entity->article_id,
    author_id => $entity->author_id,
    parent_comment_id => $entity->parent_comment_id
  };
}

1;