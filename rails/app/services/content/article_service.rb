module Content
  class ArticleService
    def initialize(repository = Article)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def publish(id)
      instance = Article.find(id)
      instance.publish()
      instance.save!
    end

    def archive(id)
      instance = Article.find(id)
      instance.archive()
      instance.save!
    end

    def increment_view(id)
      instance = Article.find(id)
      instance.increment_view()
      instance.save!
    end

    def reading_time_minutes(id)
      instance = Article.find(id)
      result = instance.reading_time_minutes()
      instance.save!
      result
    end
  end
end
