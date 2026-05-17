module Tournaments
  class GameService
    def initialize(repository = Game)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def record_winner(id, winner_side)
      instance = Game.find(id)
      instance.record_winner(winner_side)
      instance.save!
    end
  end
end
