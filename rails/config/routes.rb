Rails.application.routes.draw do
  namespace :api do
    resources :cards, module: 'cards' do
      member do
        post :ban, action: :ban
        post :unban, action: :unban
        post :restrict, action: :restrict
        post :unrestrict, action: :unrestrict
        get :value, action: :calculate_value
      end
    end
    resources :card_sets, module: 'cards'
    resources :card_rulings, module: 'cards'
    resources :card_abilities, module: 'cards'
    resources :decks, module: 'cards' do
      member do
        get :validate, action: :validate_size
        post :clone, action: :clone
        post :publish, action: :publish
        post :unpublish, action: :unpublish
        post :certify, action: :certify_tournament_legal
      end
    end
    resources :deck_cards, module: 'cards'
    resources :deck_sideboard_cards, module: 'cards'
    resources :deck_tags, module: 'cards' do
      member do
        post :merge, action: :merge_into
      end
    end
    resources :deck_tag_assignments, module: 'cards'
    resources :players, module: 'players' do
      member do
        post :promote, action: :promote
        post :demote, action: :demote
        post :win, action: :record_win
        post :loss, action: :record_loss
        get :win_rate, action: :win_rate
        post :verify, action: :verify
        patch :rating, action: :update_rating
      end
    end
    resources :player_season_statses, module: 'players'
    resources :player_collections, module: 'players' do
      member do
        get :value, action: :estimated_value
      end
    end
    resources :friendships, module: 'players' do
      member do
        post :accept, action: :accept
        post :decline, action: :decline
        post :block, action: :block
      end
    end
    resources :achievements, module: 'players'
    resources :player_achievements, module: 'players'
    resources :crafting_recipes, module: 'players'
    resources :crafting_ingredients, module: 'players'
    resources :seasons, module: 'tournaments' do
      member do
        post :activate, action: :activate
        post :deactivate, action: :deactivate
        post :finalize, action: :finalize_rewards
      end
    end
    resources :tournaments, module: 'tournaments' do
      member do
        post :start, action: :start
        post :cancel, action: :cancel
        post :complete, action: :complete
        post :rounds, action: :generate_round
        get :prizes, action: :calculate_prize_distribution
      end
    end
    resources :tournament_judges, module: 'tournaments'
    resources :tournament_registrations, module: 'tournaments' do
      member do
        post :withdraw, action: :withdraw
        post :disqualify, action: :disqualify
        post :promote, action: :promote_from_waitlist
      end
    end
    resources :tournament_rounds, module: 'tournaments' do
      member do
        post :start, action: :start
        post :complete, action: :complete
        post :pairings, action: :generate_pairings
      end
    end
    resources :matches, module: 'tournaments' do
      member do
        post :record, action: :record_result
        get :winner, action: :determine_winner
        post :draw, action: :draw
      end
    end
    resources :games, module: 'tournaments' do
      member do
        post :winner, action: :record_winner
      end
    end
    resources :tournament_prizes, module: 'tournaments'
    resources :awarded_prizes, module: 'tournaments'
    resources :products, module: 'marketplace' do
      member do
        post :activate, action: :activate
        post :deactivate, action: :deactivate
        patch :discount, action: :apply_discount
        post :restock, action: :restock
      end
    end
    resources :orders, module: 'marketplace' do
      member do
        delete :cancel, action: :cancel
        post :pay, action: :pay
        get :total, action: :calculate_total
        patch :discount, action: :apply_discount
        post :refund, action: :refund
      end
    end
    resources :order_items, module: 'marketplace'
    resources :coupons, module: 'marketplace' do
      member do
        post :redeem, action: :redeem
        post :deactivate, action: :deactivate
      end
    end
    resources :tradelistings, module: 'marketplace' do
      member do
        post :close, action: :close
        patch :extend, action: :extend
        delete :cancel, action: :cancel
      end
    end
    resources :trade_bids, module: 'marketplace'
    resources :trade_transactions, module: 'marketplace' do
      member do
        post :complete, action: :complete
        post :refund, action: :refund
        post :dispute, action: :open_dispute
      end
    end
    resources :card_price_histories, module: 'marketplace'
    resources :trade_disputes, module: 'marketplace' do
      member do
        post :escalate, action: :escalate
        post :resolve, action: :resolve
        post :review, action: :review
      end
    end
    resources :draft_sessions, module: 'content' do
      member do
        post :start, action: :start
        post :abandon, action: :abandon
        post :complete, action: :complete
      end
    end
    resources :draft_participants, module: 'content' do
      member do
        post :pick, action: :pick_card
      end
    end
    resources :draft_picks, module: 'content'
    resources :articles, module: 'content' do
      member do
        post :publish, action: :publish
        post :archive, action: :archive
        post :view, action: :increment_view
      end
    end
    resources :article_tags, module: 'content'
    resources :article_tag_assignments, module: 'content'
    resources :article_comments, module: 'content' do
      member do
        post :hide, action: :hide
        post :unhide, action: :unhide
      end
    end
    resources :streams, module: 'content' do
      member do
        post :live, action: :go_live
        post :end, action: :end
        patch :viewers, action: :update_viewer_peak
      end
    end
  end
end
