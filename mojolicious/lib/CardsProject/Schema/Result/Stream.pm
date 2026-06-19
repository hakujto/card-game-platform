package CardsProject::Schema::Result::Stream;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('streams');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  title => { data_type => 'varchar', size => 300 },
  stream_url => { data_type => 'varchar' },
  status => { data_type => 'varchar', size => 50, default_value => 'Scheduled' },
  platform => { data_type => 'varchar', size => 50, default_value => 'Twitch' },
  language => { data_type => 'varchar', size => 50, default_value => 'EN' },
  is_official => { data_type => 'boolean', default_value => 0 },
  viewer_count_peak => { data_type => 'integer', default_value => 0 },
  scheduled_start => { data_type => 'datetime' },
  actual_start => { data_type => 'datetime', is_nullable => 1 },
  ended_at => { data_type => 'datetime', is_nullable => 1 },
  vod_url => { data_type => 'varchar', is_nullable => 1 },
  tournament_id => { data_type => 'integer', is_nullable => 1 },
  streamer_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'tournament',
  'CardsProject::Schema::Result::Tournament',
  { 'foreign.id' => 'self.tournament_id' },
  { on_delete => 'SET NULL', on_update => 'CASCADE' }
);
__PACKAGE__->belongs_to(
  'streamer',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.streamer_id' },
  { on_delete => 'RESTRICT', on_update => 'CASCADE' }
);

1;
