package CardsProject::Controller::Marketplace::Product;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list ($c) {
  my $q = $c->param('q');
  my @items;
  if ($q) {
    @items = $c->schema->resultset('Product')->search(
      [     { name => { like => "%${q}%" } },
    { description => { like => "%${q}%" } } ]
    );
  } else {
    @items = $c->schema->resultset('Product')->all;
  }
  $c->render(json => [map { _to_hash($_) } @items]);
}

sub show ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Product')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => _to_hash($entity));
}

sub create ($c) {
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'product_type', 'price', 'stock', 'active', 'discount_percent', 'description', 'image_url', 'featured', 'card_id', 'card_set_id');
  my $entity = $c->schema->resultset('Product')->create(\%cols);
  $c->render(status => 201, json => _to_hash($entity));
}

sub update ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Product')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  my $data = $c->req->json;
  my $errors = _validate($data);
  return $c->render(status => 422, json => { errors => $errors }) if @$errors;
  my %cols = map { $_ => $data->{$_} } grep { defined $data->{$_} } ('name', 'product_type', 'price', 'stock', 'active', 'discount_percent', 'description', 'image_url', 'featured', 'card_id', 'card_set_id');
  $entity->update(\%cols);
  $c->render(json => _to_hash($entity));
}

sub activate ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Product')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub deactivate ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Product')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub apply_discount ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Product')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub restock ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Product')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub effective_price ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Product')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub is_in_stock ($c) {
  my $id = $c->param('id');
  my $entity = $c->schema->resultset('Product')->find($id)
    or return $c->render(status => 404, json => { error => 'Not found' });
  $c->render(json => { status => 'ok' });
}

sub _validate ($data) {
  my @errors;
  if (defined $data->{discount_percent} && $data->{discount_percent} < 0) {
    push @errors, 'discount_percent must be >= 0';
  }
  if (defined $data->{discount_percent} && $data->{discount_percent} > 100) {
    push @errors, 'discount_percent must be <= 100';
  }
  return \@errors;
}

sub _to_hash ($entity) {
  return {
    id => $entity->id,
    name => $entity->name,
    product_type => $entity->product_type,
    price => $entity->price,
    stock => $entity->stock,
    active => $entity->active,
    discount_percent => $entity->discount_percent,
    description => $entity->description,
    image_url => $entity->image_url,
    featured => $entity->featured,
    card_id => $entity->card_id,
    card_set_id => $entity->card_set_id
  };
}

1;