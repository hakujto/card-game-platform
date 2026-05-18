module Cards
  class DeckSideboardCardService
    def initialize(repository = DeckSideboardCard)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def increment(id, amount)
      instance = DeckSideboardCard.find(id)
      instance.increment(amount)
      instance.save!
    end

    def decrement(id, amount)
      instance = DeckSideboardCard.find(id)
      instance.decrement(amount)
      instance.save!
    end
  end
end
