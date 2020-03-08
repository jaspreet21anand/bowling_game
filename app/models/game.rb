class Game < ApplicationRecord
  MAX_FRAMES = 10

  has_many :frames, dependent: :destroy
  has_many :throws, through: :frames

  before_validation :set_default_state, on: :create

  validates :state, presence: true
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  enum state: { open: 0, completed: 1, expired: 2 }

  def mark_completed
    update(state: :completed)
  end

  def update_score
    update(score: frames.sum(:score))
  end

  def score_details
    {
      total_score: score,
      game_state: state,
      frames: frames.includes(:throws).order(:created_at).inject([]) { |result, frame| result << { throws: frame.throws.order(:created_at).pluck(:knocked_pins), score: frame.score, c_score: (result.last.try(:[],:c_score).to_i + frame.score) }; result }
    }
  end

  private
    def set_default_state
      self.state = :open
    end
end
