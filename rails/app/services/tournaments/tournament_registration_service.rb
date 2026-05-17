module Tournaments
  class TournamentRegistrationService
    def initialize(repository = TournamentRegistration)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def withdraw(id)
      instance = TournamentRegistration.find(id)
      instance.withdraw()
      instance.save!
    end

    def disqualify(id, reason)
      instance = TournamentRegistration.find(id)
      instance.disqualify(reason)
      instance.save!
    end

    def promote_from_waitlist(id)
      instance = TournamentRegistration.find(id)
      instance.promote_from_waitlist()
      instance.save!
    end
  end
end
