module Content
  class ArticleCommentService
    def initialize(repository = ArticleComment)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def hide(id)
      instance = ArticleComment.find(id)
      instance.hide()
      instance.save!
    end

    def unhide(id)
      instance = ArticleComment.find(id)
      instance.unhide()
      instance.save!
    end
  end
end
