module Players
  class PlayerAchievementService
    def initialize(repository = PlayerAchievement)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def increment_progress(id, amount)
      instance = PlayerAchievement.find(id)
      instance.increment_progress(amount)
      instance.save!
    end

    def complete(id)
      instance = PlayerAchievement.find(id)
      instance.complete()
      instance.save!
    end

    # triggered by @on(is_completed = true)
    def set_is_completed(id, value)
      instance = PlayerAchievement.find(id)
      instance.is_completed = value
      if value.to_s.upcase == 'TRUE'
        instance.complete
      end
      instance.save!
    end
  end
end
