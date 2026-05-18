module Content
  class ArticleTagService
    def initialize(repository = ArticleTag)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def rename(id, new_name)
      instance = ArticleTag.find(id)
      instance.rename(new_name)
      instance.save!
    end

    def article_count(id)
      instance = ArticleTag.find(id)
      result = instance.article_count()
      instance.save!
      result
    end
  end
end
