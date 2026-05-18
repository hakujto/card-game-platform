module Cards
  class CardAbilityService
    def initialize(repository = CardAbility)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def is_usable_at(id)
      instance = CardAbility.find(id)
      result = instance.is_usable_at(timing)
      instance.save!
      result
    end

    def describe(id)
      instance = CardAbility.find(id)
      result = instance.describe()
      instance.save!
      result
    end
  end
end
