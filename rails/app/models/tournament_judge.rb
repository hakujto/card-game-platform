class TournamentJudge < ApplicationRecord
  self.table_name = 'tournament_judges'

  enum :role, { head_judge: 0, judge: 1, scorekeeper_judge: 2 }

  belongs_to :tournament, class_name: 'Tournament', inverse_of: :judge_assignments
  belongs_to :player, class_name: 'Player', inverse_of: :judge_roles

  def to_s
    role.to_s
  end

  # Business operations

  def promote_to_head
    # TODO: implement promote_to_head
  end

  def remove
    # TODO: implement remove
  end
end
