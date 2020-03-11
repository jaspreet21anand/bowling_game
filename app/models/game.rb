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
      frames: frames.includes(:throws).order(:created_at).map { |frame|
        frame.as_json(include: {
          throws: { only: [:knocked_pins, :knock_type] }
        }, only: [:state, :score])
      }
    }
  end

  def current_frame
    frames.find_or_create_by(state: :open)
  end

  private
    def set_default_state
      self.state = :open
    end
end
