module Content
  class DraftParticipantService
    def initialize(repository = DraftParticipant)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def pick_card(id, card_id, pack_number)
      instance = DraftParticipant.find(id)
      instance.pick_card(card_id, pack_number)
      instance.save!
    end

    def drafted_card_count(id)
      instance = DraftParticipant.find(id)
      result = instance.drafted_card_count()
      instance.save!
      result
    end
  end
end
