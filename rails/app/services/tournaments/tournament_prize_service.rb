module Tournaments
  class TournamentPrizeService
    def initialize(repository = TournamentPrize)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def applies_to_placement(id)
      instance = TournamentPrize.find(id)
      result = instance.applies_to_placement(placement)
      instance.save!
      result
    end

    def award_to_player(id, player_id)
      instance = TournamentPrize.find(id)
      instance.award_to_player(player_id)
      instance.save!
    end
  end
end
