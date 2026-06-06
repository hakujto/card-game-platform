package CardsProject::Service::Tournaments::Tournament;
use strict;
use warnings;

sub new {
  my ($class, %args) = @_;
  return bless { schema => $args{schema} }, $class;
}

sub find_all {
  my ($self) = @_;
  return [$self->{schema}->resultset('Tournament')->all];
}

sub find_by_id {
  my ($self, $id) = @_;
  return $self->{schema}->resultset('Tournament')->find($id);
}

sub create {
  my ($self, $data) = @_;
  return $self->{schema}->resultset('Tournament')->create($data);
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
