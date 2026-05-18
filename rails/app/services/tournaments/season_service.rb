module Tournaments
  class SeasonService
    def initialize(repository = Season)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def activate(id)
      instance = Season.find(id)
      instance.activate()
      instance.save!
    end

    def deactivate(id)
      instance = Season.find(id)
      instance.deactivate()
      instance.save!
    end

    def finalize_rewards(id)
      instance = Season.find(id)
      instance.finalize_rewards()
      instance.save!
    end

    def is_ongoing(id)
      instance = Season.find(id)
      result = instance.is_ongoing()
      instance.save!
      result
    end
  end
end
