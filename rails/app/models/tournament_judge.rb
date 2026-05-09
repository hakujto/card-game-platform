class TournamentJudge < ApplicationRecord
  self.table_name = 'tournament_judges'

  enum :role, { head_judge: 0, judge: 1, scorekeeper_judge: 2 }

  belongs_to :tournament, class_name: 'Tournament'
  belongs_to :player, class_name: 'Player'

  def to_s
    role.to_s
  end
end
