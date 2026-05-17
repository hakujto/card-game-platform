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

    def estimated_value(id)
      instance = PlayerCollection.find(id)
      result = instance.estimated_value()
      instance.save!
      result
    end
  end
end
