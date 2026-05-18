module Players
  class PlayerSeasonStatsService
    def initialize(repository = PlayerSeasonStats)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def win_rate(id)
      instance = PlayerSeasonStats.find(id)
      result = instance.win_rate()
      instance.save!
      result
    end

    def add_points(id, points)
      instance = PlayerSeasonStats.find(id)
      instance.add_points(points)
      instance.save!
    end

    def record_tournament_win(id)
      instance = PlayerSeasonStats.find(id)
      instance.record_tournament_win()
      instance.save!
    end
  end
end
