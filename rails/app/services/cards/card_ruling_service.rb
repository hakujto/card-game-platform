module Cards
  class CardRulingService
    def initialize(repository = CardRuling)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def is_current(id)
      instance = CardRuling.find(id)
      result = instance.is_current()
      instance.save!
      result
    end

    def supersedes_previous(id)
      instance = CardRuling.find(id)
      result = instance.supersedes_previous()
      instance.save!
      result
    end
  end
end
