module Content
  class DraftSessionService
    def initialize(repository = DraftSession)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def start(id)
      instance = DraftSession.find(id)
      instance.start()
      instance.save!
    end

    def abandon(id)
      instance = DraftSession.find(id)
      instance.abandon()
      instance.save!
    end

    def complete(id)
      instance = DraftSession.find(id)
      instance.complete()
      instance.save!
    end

    def is_full(id)
      instance = DraftSession.find(id)
      result = instance.is_full()
      instance.save!
      result
    end
  end
end
