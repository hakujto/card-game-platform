package CardsProject::Event::Tournament::TournamentCompleted;
use strict;
use warnings;

sub new {
  my ($class, %args) = @_;
  return bless {
    tournament_id => $args{tournament_id},
    season_id => $args{season_id},
    completed_at => $args{completed_at},
  }, $class;
}

sub tournament_id { $_[0]->{tournament_id} }
sub season_id { $_[0]->{season_id} }
sub completed_at { $_[0]->{completed_at} }

package CardsProject::Event::Tournament::PlayerRegistered;
use strict;
use warnings;

sub new {
  my ($class, %args) = @_;
  return bless {
    tournament_id => $args{tournament_id},
    player_id => $args{player_id},
    registered_at => $args{registered_at},
  }, $class;
}

sub tournament_id { $_[0]->{tournament_id} }
sub player_id { $_[0]->{player_id} }
sub registered_at { $_[0]->{registered_at} }

1;