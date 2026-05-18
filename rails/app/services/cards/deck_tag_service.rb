module Cards
  class DeckTagService
    def initialize(repository = DeckTag)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def rename(id, new_name)
      instance = DeckTag.find(id)
      instance.rename(new_name)
      instance.save!
    end

    def merge_into(id, target_tag_id)
      instance = DeckTag.find(id)
      instance.merge_into(target_tag_id)
      instance.save!
    end
  end
end
