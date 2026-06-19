package CardsProject::Schema::Result::Deck;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('decks');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  name => { data_type => 'varchar', size => 100 },
  description => { data_type => 'text', is_nullable => 1 },
  format => { data_type => 'varchar', size => 50, default_value => 'Standard' },
  is_public => { data_type => 'boolean', default_value => 0 },
  is_tournament_legal => { data_type => 'boolean', default_value => 0 },
  archetype => { data_type => 'varchar', size => 50, is_nullable => 1 },
  wins => { data_type => 'integer', default_value => 0 },
  losses => { data_type => 'integer', default_value => 0 },
  draws => { data_type => 'integer', default_value => 0 },
  created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  updated_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  player_id => { data_type => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'player',
  'CardsProject::Schema::Result::Player',
  { 'foreign.id' => 'self.player_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->has_many('deck_cards' => 'CardsProject::Schema::Result::DeckCard', 'deck_id');
__PACKAGE__->many_to_many('cards', 'deck_cards', 'card');
__PACKAGE__->has_many('tag_assignments' => 'CardsProject::Schema::Result::DeckTagAssignment', 'deck_id');
__PACKAGE__->many_to_many('deck_tags', 'tag_assignments', 'tag');
__PACKAGE__->has_many('sideboard_cards' => 'CardsProject::Schema::Result::DeckSideboardCard', 'deck_id');
__PACKAGE__->has_many('tournament_registrations' => 'CardsProject::Schema::Result::TournamentRegistration', 'deck_id');
__PACKAGE__->has_many('articles' => 'CardsProject::Schema::Result::Article', 'featured_deck_id');

sub insert_or_update {
  my ($self, @args) = @_;
  my $result = $self->next::method(@args);
  &recalculate_tournament_legal($result);
  return $result;
}

sub recalculate_tournament_legal { }

1;
