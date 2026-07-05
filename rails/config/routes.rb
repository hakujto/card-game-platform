Rails.application.routes.draw do
  namespace :api do
    resources :cards, module: 'cards', only: [:index, :show, :create, :update] do
      member do
        post :ban, action: :ban
        post :unban, action: :unban
        post :restrict, action: :restrict
        post :unrestrict, action: :unrestrict
        put :replace, action: :replace
        get :value, action: :calculate_value
        post :rarity_bonus, action: :apply_rarity_bonus
        get :legal, action: :is_legal_in_format
      end
    end
    resources :card_sets, module: 'cards', only: [:index, :show, :create, :update] do
      member do
        get :standard_legal, action: :is_legal_in_standard
        get :legal, action: :is_legal_in_format
        get :rarity_count, action: :card_count_by_rarity
        post :rotate, action: :rotate_out
      end
    end
    resources :card_rulings, module: 'cards', only: [:index, :show, :create, :destroy] do
      member do
        get :current, action: :is_current
        get :supersedes, action: :supersedes_previous
      end
    end
    resources :card_abilities, module: 'cards' do
      member do
        get :usable, action: :is_usable_at
        get :describe, action: :describe
      end
    end
    resources :decks, module: 'cards' do
      member do
        get :validate, action: :validate_size
        post :cards, action: :add_card
        delete 'cards/:card_id', action: :remove_card
        get :win_rate, action: :win_rate
        post :clone, action: :clone
        post :publish, action: :publish
        post :unpublish, action: :unpublish
        post :certify, action: :certify_tournament_legal
      end
    end
    resources :deck_cards, module: 'cards' do
      member do
        patch :increment, action: :increment
        patch :decrement, action: :decrement
      end
    end
    resources :deck_sideboard_cards, module: 'cards' do
      member do
        patch :increment, action: :increment
        patch :decrement, action: :decrement
      end
    end
    resources :deck_tags, module: 'cards' do
      member do
        patch :rename, action: :rename
        post :merge, action: :merge_into
      end
    end
    resources :deck_tag_assignments, module: 'cards', only: [:index, :show, :create, :destroy]
    resources :players, module: 'players', only: [:index, :show, :create, :update] do
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
    resources :player_season_statses, module: 'players', only: [:index, :show] do
      member do
        get :win_rate, action: :win_rate
        patch :points, action: :add_points
        post :tournament_win, action: :record_tournament_win
      end
    end
    resources :player_collections, module: 'players' do
      member do
        post :add, action: :add
        post :remove, action: :remove
        get :value, action: :estimated_value
      end
    end
    resources :friendships, module: 'players', only: [:index, :show, :create, :destroy] do
      member do
        post :accept, action: :accept
        post :decline, action: :decline
        post :block, action: :block
      end
    end
    resources :achievements, module: 'players', only: [:index, :show, :create, :update] do
      member do
        get :point_value, action: :point_value
        post :reveal, action: :reveal
      end
    end
    resources :player_achievements, module: 'players', only: [:index, :show] do
      member do
        patch :progress, action: :increment_progress
        post :complete, action: :complete
      end
    end
    resources :crafting_recipes, module: 'players', only: [:index, :show, :create, :update] do
      member do
        get :can_craft, action: :can_craft
        post :craft, action: :execute_craft
        post :disable, action: :disable
        post :enable, action: :enable
      end
    end
    resources :crafting_ingredients, module: 'players', only: [:index, :show, :create, :destroy]
    resources :seasons, module: 'tournaments', only: [:index, :show, :create, :update] do
      member do
        post :activate, action: :activate
        post :deactivate, action: :deactivate
        post :finalize, action: :finalize_rewards
        get :ongoing, action: :is_ongoing
      end
    end
    resources :tournaments, module: 'tournaments', only: [:index, :show, :create, :update] do
      member do
        post :start, action: :start
        post :cancel, action: :cancel
        post :complete, action: :complete
        post :rounds, action: :generate_round
        get :prizes, action: :calculate_prize_distribution
        post :register, action: :register_player
        get :full, action: :is_full
        patch 'transitions/draft-to-registration', action: :transition_draft_to_registration
        patch 'transitions/registration-to-ongoing', action: :transition_registration_to_ongoing
        patch 'transitions/registration-to-cancelled', action: :transition_registration_to_cancelled
        patch 'transitions/ongoing-to-completed', action: :transition_ongoing_to_completed
        patch 'transitions/ongoing-to-cancelled', action: :transition_ongoing_to_cancelled
        patch 'transitions/completed-to-draft', action: :transition_completed_to_draft
        patch 'transitions/cancelled-to-draft', action: :transition_cancelled_to_draft
      end
    end
    resources :tournament_judges, module: 'tournaments', only: [:index, :show, :create, :destroy] do
      member do
        post :promote, action: :promote_to_head
        delete :remove, action: :remove
      end
    end
    resources :tournament_registrations, module: 'tournaments', only: [:index, :show, :create] do
      member do
        post :withdraw, action: :withdraw
        post :disqualify, action: :disqualify
        post :promote, action: :promote_from_waitlist
      end
    end
    resources :tournament_rounds, module: 'tournaments', only: [:index, :show, :create] do
      member do
        post :start, action: :start
        post :complete, action: :complete
        post :pairings, action: :generate_pairings
        get :time_expired, action: :is_time_expired
      end
    end
    resources :matches, module: 'tournaments', only: [:index, :show, :create] do
      member do
        post :record, action: :record_result
        post :finalize, action: :finalize_result
        get :winner, action: :determine_winner
        post :concede, action: :concede
        post :draw, action: :draw
        patch 'transitions/pending-to-active', action: :transition_pending_to_active
        patch 'transitions/active-to-completed', action: :transition_active_to_completed
        patch 'transitions/active-to-draw', action: :transition_active_to_draw
        patch 'transitions/pending-to-bye', action: :transition_pending_to_bye
        patch 'transitions/completed-to-active', action: :transition_completed_to_active
        patch 'transitions/draw-to-active', action: :transition_draw_to_active
        patch 'transitions/bye-to-active', action: :transition_bye_to_active
      end
    end
    resources :games, module: 'tournaments', only: [:index, :show, :create] do
      member do
        post :winner, action: :record_winner
        get :duration, action: :duration_minutes
      end
    end
    resources :tournament_prizes, module: 'tournaments' do
      member do
        get :applies, action: :applies_to_placement
        post :award, action: :award_to_player
      end
    end
    resources :awarded_prizes, module: 'tournaments', only: [:index, :show] do
      member do
        post :claim, action: :claim
      end
    end
    resources :products, module: 'marketplace', only: [:index, :show, :create, :update] do
      member do
        post :activate, action: :activate
        post :deactivate, action: :deactivate
        patch :discount, action: :apply_discount
        post :restock, action: :restock
        get :effective_price, action: :effective_price
        get :in_stock, action: :is_in_stock
      end
    end
    resources :orders, module: 'marketplace', only: [:index, :show, :create] do
      member do
        delete :cancel, action: :cancel
        post :pay, action: :pay
        post :process_payment, action: :process_payment
        get :total, action: :calculate_total
        patch :discount, action: :apply_discount
        post :refund, action: :refund
        patch 'transitions/pending-to-paid', action: :transition_pending_to_paid
        patch 'transitions/paid-to-processing', action: :transition_paid_to_processing
        patch 'transitions/processing-to-shipped', action: :transition_processing_to_shipped
        patch 'transitions/shipped-to-completed', action: :transition_shipped_to_completed
        patch 'transitions/pending-to-cancelled', action: :transition_pending_to_cancelled
        patch 'transitions/paid-to-cancelled', action: :transition_paid_to_cancelled
        patch 'transitions/completed-to-refunded', action: :transition_completed_to_refunded
        patch 'transitions/refunded-to-completed', action: :transition_refunded_to_completed
        patch 'transitions/completed-to-cancelled', action: :transition_completed_to_cancelled
      end
    end
    resources :order_items, module: 'marketplace', only: [:index, :show, :create, :destroy] do
      member do
        get :total, action: :line_total
      end
    end
    resources :coupons, module: 'marketplace', only: [:index, :show, :create, :update] do
      member do
        get :valid, action: :is_valid
        get :applicable, action: :is_applicable_to_order
        post :redeem, action: :redeem
        post :deactivate, action: :deactivate
      end
    end
    resources :trade_listings, module: 'marketplace', only: [:index, :show, :create, :update] do
      member do
        post :close, action: :close
        patch :extend, action: :extend
        delete :cancel, action: :cancel
        get :expired, action: :is_expired
        post :finalize, action: :finalize_auction
        patch 'transitions/pending-to-active', action: :transition_pending_to_active
        patch 'transitions/active-to-sold', action: :transition_active_to_sold
        patch 'transitions/active-to-expired', action: :transition_active_to_expired
        patch 'transitions/active-to-cancelled', action: :transition_active_to_cancelled
        patch 'transitions/sold-to-active', action: :transition_sold_to_active
        patch 'transitions/expired-to-active', action: :transition_expired_to_active
      end
    end
    resources :trade_bids, module: 'marketplace', only: [:index, :show, :create] do
      member do
        get :outbid, action: :outbid_by
        delete :retract, action: :retract
      end
    end
    resources :trade_transactions, module: 'marketplace', only: [:index, :show] do
      member do
        post :complete, action: :complete
        post :refund, action: :refund
        post :dispute, action: :open_dispute
        get :seller_net, action: :seller_net
      end
    end
    resources :card_price_histories, module: 'marketplace', only: [:index, :show] do
      member do
        get :change, action: :price_change_percent
        get :spike, action: :is_price_spike
      end
    end
    resources :trade_disputes, module: 'marketplace', only: [:index, :show, :create] do
      member do
        post :escalate, action: :escalate
        post :resolve, action: :resolve
        post :close, action: :close_resolved
        post :review, action: :review
        patch 'transitions/open-to-underreview', action: :transition_open_to_underreview
        patch 'transitions/underreview-to-resolved', action: :transition_underreview_to_resolved
        patch 'transitions/underreview-to-escalated', action: :transition_underreview_to_escalated
        patch 'transitions/escalated-to-resolved', action: :transition_escalated_to_resolved
        patch 'transitions/resolved-to-open', action: :transition_resolved_to_open
      end
    end
    resources :draft_sessions, module: 'content', only: [:index, :show, :create] do
      member do
        post :start, action: :start
        post :abandon, action: :abandon
        post :complete, action: :complete
        get :full, action: :is_full
        patch 'transitions/waitingforplayers-to-drafting', action: :transition_waitingforplayers_to_drafting
        patch 'transitions/drafting-to-completed', action: :transition_drafting_to_completed
        patch 'transitions/drafting-to-abandoned', action: :transition_drafting_to_abandoned
        patch 'transitions/waitingforplayers-to-abandoned', action: :transition_waitingforplayers_to_abandoned
        patch 'transitions/completed-to-drafting', action: :transition_completed_to_drafting
        patch 'transitions/abandoned-to-drafting', action: :transition_abandoned_to_drafting
      end
    end
    resources :draft_participants, module: 'content', only: [:index, :show, :create] do
      member do
        post :pick, action: :pick_card
        get :card_count, action: :drafted_card_count
      end
    end
    resources :draft_picks, module: 'content', only: [:index, :show] do
      member do
        get :first_pick, action: :is_first_pick
      end
    end
    resources :articles, module: 'content', only: [:index, :show, :create, :update] do
      member do
        post :publish, action: :publish
        post :archive, action: :archive
        put :replace, action: :replace
        post :view, action: :increment_view
        post :like, action: :like
        delete :like, action: :unlike
        get :reading_time, action: :reading_time_minutes
        patch 'transitions/draft-to-published', action: :transition_draft_to_published
        patch 'transitions/published-to-archived', action: :transition_published_to_archived
        patch 'transitions/archived-to-draft', action: :transition_archived_to_draft
        patch 'transitions/published-to-draft', action: :transition_published_to_draft
      end
    end
    resources :article_tags, module: 'content' do
      member do
        patch :rename, action: :rename
        get :article_count, action: :article_count
      end
    end
    resources :article_tag_assignments, module: 'content', only: [:index, :show, :create, :destroy]
    resources :article_comments, module: 'content', only: [:index, :show, :create, :destroy] do
      member do
        post :hide, action: :hide
        post :unhide, action: :unhide
        get :is_reply, action: :is_reply
      end
    end
    resources :streams, module: 'content', only: [:index, :show, :create, :update] do
      member do
        post :live, action: :go_live
        post :end, action: :end
        patch :viewers, action: :update_viewer_peak
        get :duration, action: :duration_minutes
        patch 'transitions/scheduled-to-live', action: :transition_scheduled_to_live
        patch 'transitions/live-to-ended', action: :transition_live_to_ended
        patch 'transitions/ended-to-live', action: :transition_ended_to_live
      end
    end
  end
end
