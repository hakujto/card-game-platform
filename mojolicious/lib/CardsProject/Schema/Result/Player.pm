package CardsProject::Schema::Result::Player;
use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->table('players');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', is_auto_increment => 1 },
  public_id => { data_type => 'varchar', is_unique => 1 },
  display_name => { data_type => 'varchar', size => 50, is_unique => 1 },
  rank => { data_type => 'varchar', size => 50, default_value => 'Bronze' },
  rating => { data_type => 'integer', default_value => 1000 },
  peak_rating => { data_type => 'integer', default_value => 1000 },
  bio => { data_type => 'text', is_nullable => 1 },
  country_code => { data_type => 'varchar', size => 2, is_nullable => 1 },
  avatar_url => { data_type => 'varchar', is_nullable => 1 },
  preferred_format => { data_type => 'varchar', size => 50, is_nullable => 1 },
  contact_email => { data_type => 'varchar', is_nullable => 1 },
  win_rate_cached => { data_type => 'float', is_nullable => 1 },
  is_verified => { data_type => 'boolean', default_value => 0 },
  created_at => { data_type => 'datetime', default_value => \'CURRENT_TIMESTAMP' },
  last_active_at => { data_type => 'datetime', is_nullable => 1 },
  user_id => { data_type => 'integer', is_nullable => 1, is_unique => 1 }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(
  'user',
  'CardsProject::Schema::Result::User',
  { 'foreign.id' => 'self.user_id' },
  { on_delete => 'CASCADE', on_update => 'CASCADE' }
);
__PACKAGE__->has_many('achievement_records' => 'CardsProject::Schema::Result::PlayerAchievement', 'player_id');
__PACKAGE__->many_to_many('achievements', 'achievement_records', 'achievement');
__PACKAGE__->has_many('sent_friend_requests' => 'CardsProject::Schema::Result::Friendship', 'requester_id');
__PACKAGE__->many_to_many('players', 'sent_friend_requests', 'requester');
__PACKAGE__->has_many('decks' => 'CardsProject::Schema::Result::Deck', 'player_id');
__PACKAGE__->has_many('season_stats' => 'CardsProject::Schema::Result::PlayerSeasonStats', 'player_id');
__PACKAGE__->has_many('collection' => 'CardsProject::Schema::Result::PlayerCollection', 'player_id');
__PACKAGE__->has_many('received_friend_requests' => 'CardsProject::Schema::Result::Friendship', 'receiver_id');
__PACKAGE__->has_many('organized_tournaments' => 'CardsProject::Schema::Result::Tournament', 'organizer_id');
__PACKAGE__->has_many('judge_roles' => 'CardsProject::Schema::Result::TournamentJudge', 'player_id');
__PACKAGE__->has_many('tournament_registrations' => 'CardsProject::Schema::Result::TournamentRegistration', 'player_id');
__PACKAGE__->has_many('matches_as_player1' => 'CardsProject::Schema::Result::Match', 'player1_id');
__PACKAGE__->has_many('matches_as_player2' => 'CardsProject::Schema::Result::Match', 'player2_id');
__PACKAGE__->has_many('won_games' => 'CardsProject::Schema::Result::Game', 'winner_id');
__PACKAGE__->has_many('awarded_prizes' => 'CardsProject::Schema::Result::AwardedPrize', 'player_id');
__PACKAGE__->has_many('orders' => 'CardsProject::Schema::Result::Order', 'player_id');
__PACKAGE__->has_many('trade_listings' => 'CardsProject::Schema::Result::TradeListing', 'seller_id');
__PACKAGE__->has_many('bids' => 'CardsProject::Schema::Result::TradeBid', 'bidder_id');
__PACKAGE__->has_many('purchases' => 'CardsProject::Schema::Result::TradeTransaction', 'buyer_id');
__PACKAGE__->has_many('sales' => 'CardsProject::Schema::Result::TradeTransaction', 'seller_id');
__PACKAGE__->has_many('disputes_opened' => 'CardsProject::Schema::Result::TradeDispute', 'opened_by_id');
__PACKAGE__->has_many('disputes_resolved' => 'CardsProject::Schema::Result::TradeDispute', 'resolved_by_id');
__PACKAGE__->has_many('draft_sessions' => 'CardsProject::Schema::Result::DraftParticipant', 'player_id');
__PACKAGE__->has_many('articles' => 'CardsProject::Schema::Result::Article', 'author_id');
__PACKAGE__->has_many('article_comments' => 'CardsProject::Schema::Result::ArticleComment', 'author_id');
__PACKAGE__->has_many('streams' => 'CardsProject::Schema::Result::Stream', 'streamer_id');

sub initialize_collection { }

sub update_rank { }

1;
