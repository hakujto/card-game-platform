module Tournaments
  class TournamentRoundService
    def initialize(repository = TournamentRound)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def start(id)
      instance = TournamentRound.find(id)
      instance.start()
      instance.save!
    end

    def complete(id)
      instance = TournamentRound.find(id)
      instance.complete()
      instance.save!
    end

    def generate_pairings(id)
      instance = TournamentRound.find(id)
      instance.generate_pairings()
      instance.save!
    end

    def is_time_expired(id)
      instance = TournamentRound.find(id)
      result = instance.is_time_expired()
      instance.save!
      result
    end
  end
end
