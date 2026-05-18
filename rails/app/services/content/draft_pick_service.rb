module Content
  class DraftPickService
    def initialize(repository = DraftPick)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def is_first_pick(id)
      instance = DraftPick.find(id)
      result = instance.is_first_pick()
      instance.save!
      result
    end
  end
end
