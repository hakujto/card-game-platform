module Content
  class StreamService
    def initialize(repository = Stream)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def go_live(id)
      instance = Stream.find(id)
      instance.go_live()
      instance.save!
    end

    def end(id)
      instance = Stream.find(id)
      instance.end()
      instance.save!
    end

    def update_viewer_peak(id, count)
      instance = Stream.find(id)
      instance.update_viewer_peak(count)
      instance.save!
    end

    def duration_minutes(id)
      instance = Stream.find(id)
      result = instance.duration_minutes()
      instance.save!
      result
    end
  end
end
