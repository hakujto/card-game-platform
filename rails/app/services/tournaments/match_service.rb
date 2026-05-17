module Tournaments
  class MatchService
    def initialize(repository = Match)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def record_result(id, p1_wins, p2_wins)
      instance = Match.find(id)
      instance.record_result(p1_wins, p2_wins)
      instance.determine_winner()  # @after
      instance.save!
    end

    def determine_winner(id)
      instance = Match.find(id)
      result = instance.determine_winner()
      instance.save!
      result
    end

    def draw(id)
      instance = Match.find(id)
      instance.draw()
      instance.save!
    end
  end
end
