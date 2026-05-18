module Players
  class PlayerCollectionService
    def initialize(repository = PlayerCollection)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def add(id, quantity)
      instance = PlayerCollection.find(id)
      instance.add(quantity)
      instance.save!
    end

    def remove(id, quantity)
      instance = PlayerCollection.find(id)
      instance.remove(quantity)
      instance.save!
    end

    def estimated_value(id)
      instance = PlayerCollection.find(id)
      result = instance.estimated_value()
      instance.save!
      result
    end
  end
end
