module Cards
  class DeckService
    def initialize(repository = Deck)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def validate_size(id)
      instance = Deck.find(id)
      result = instance.validate_size()
      instance.save!
      result
    end

    def clone(id)
      instance = Deck.find(id)
      result = instance.clone()
      instance.save!
      result
    end

    def publish(id)
      instance = Deck.find(id)
      instance.publish()
      instance.save!
    end

    def unpublish(id)
      instance = Deck.find(id)
      instance.unpublish()
      instance.save!
    end

    def certify_tournament_legal(id)
      instance = Deck.find(id)
      result = instance.certify_tournament_legal()
      instance.save!
      result
    end
  end
end
