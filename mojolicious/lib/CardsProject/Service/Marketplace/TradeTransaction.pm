package CardsProject::Service::Marketplace::TradeTransaction;
use strict;
use warnings;

sub new {
  my ($class, %args) = @_;
  return bless { schema => $args{schema} }, $class;
}

sub find_all {
  my ($self) = @_;
  return [$self->{schema}->resultset('TradeTransaction')->all];
}

sub find_by_id {
  my ($self, $id) = @_;
  return $self->{schema}->resultset('TradeTransaction')->find($id);
}

sub create {
  my ($self, $data) = @_;
  return $self->{schema}->resultset('TradeTransaction')->create($data);
}

sub update {
  my ($self, $id, $data) = @_;
  my $entity = $self->find_by_id($id) or return;
  $entity->update($data);
  return $entity;
}

sub delete {
  my ($self, $id) = @_;
  my $entity = $self->find_by_id($id) or return;
  $entity->delete;
  return 1;
}

1;
