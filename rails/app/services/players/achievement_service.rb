module Players
  class AchievementService
    def initialize(repository = Achievement)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def point_value(id)
      instance = Achievement.find(id)
      result = instance.point_value(multiplier)
      instance.save!
      result
    end

    def reveal(id)
      instance = Achievement.find(id)
      instance.reveal()
      instance.save!
    end
  end
end
