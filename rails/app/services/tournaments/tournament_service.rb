module Tournaments
  class TournamentService
    def initialize(repository = Tournament)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def start(id)
      instance = Tournament.find(id)
      instance.start()
      instance.save!
    end

    def cancel(id)
      instance = Tournament.find(id)
      instance.cancel()
      instance.save!
    end

    def complete(id)
      instance = Tournament.find(id)
      instance.complete()
      instance.save!
    end

    def generate_round(id)
      instance = Tournament.find(id)
      instance.generate_round()
      instance.save!
    end

    def calculate_prize_distribution(id)
      instance = Tournament.find(id)
      result = instance.calculate_prize_distribution()
      instance.save!
      result
    end

    def register_player(id, player_id, deck_id)
      instance = Tournament.find(id)
      instance.register_player(player_id, deck_id)
      instance.save!
    end

    def is_full(id)
      instance = Tournament.find(id)
      result = instance.is_full()
      instance.save!
      result
    end
  end
end
