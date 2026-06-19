package CardsProject::Schema::Result::Friendship;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('friendships');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  status => { data_type => 'varchar', size => 50, default_value => 'Pending' },
  created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  requester_id => { data_type => 'integer', is_nullable => 1 },
  receiver_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'requester',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.requester_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'receiver',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.receiver_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);

1;
