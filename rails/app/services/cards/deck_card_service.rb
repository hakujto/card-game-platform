module Cards
  class DeckCardService
    def initialize(repository = DeckCard)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def increment(id, amount)
      instance = DeckCard.find(id)
      instance.increment(amount)
      instance.save!
    end

    def decrement(id, amount)
      instance = DeckCard.find(id)
      instance.decrement(amount)
      instance.save!
    end
  end
end
