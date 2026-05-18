module Tournaments
  class TournamentJudgeService
    def initialize(repository = TournamentJudge)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def promote_to_head(id)
      instance = TournamentJudge.find(id)
      instance.promote_to_head()
      instance.save!
    end

    def remove(id)
      instance = TournamentJudge.find(id)
      instance.remove()
      instance.save!
    end
  end
end
