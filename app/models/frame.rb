class Frame < ApplicationRecord
  MAX_PINS = 10
  MAX_THROWS_IN_LAST_FRAME = 3
  MAX_THROWS_PER_FRAME = 2

  has_many :throws, dependent: :destroy
  belongs_to :game

  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :game_should_be_open, :frame_count_within_max_frames, on: :create

  enum state: { open: 0, closed: 1 }

  after_update :update_game_score, :update_game_state, if: :score

  def update_frame_state
    mark_closed if can_be_closed?
  end

  def knocked_pins
    # [JS] @knocked_pins ||= throws.sum(:knocked_pins) # do not cache
    # asit is being called in validations in throw model
    throws.sum(:knocked_pins)
  end

  def calculate_and_update_frame_score
    return if open?
    score = calculate_score
    update(score: score) if score
  end

  def last_frame?
    @last_frame ||= (game.frames.count == Game::MAX_FRAMES &&
      game.frames.order(:created_at).last.id == self.id)
  end

  def additional_throws_awarded?
    last_frame? && with_strike_or_spare?
  end

  private
    def calculate_score
      if last_frame?
        knocked_pins
      else
        send("calculate_#{ knock_type }_score")
      end
    end

    def can_be_closed?
      if additional_throws_awarded?
        throws.size == MAX_THROWS_IN_LAST_FRAME ? true : false
      elsif with_strike_or_spare? || throws.size == MAX_THROWS_PER_FRAME
        true
      end
    end

    def mark_closed
      update(state: :closed)
    end

    def knock_type
      return if open?
      if with_strike?
        :strike
      elsif with_spare?
        :spare
      else
        :play
      end
    end

    def ordered_throws
      @ordered_throws ||= throws.order(:created_at).all
    end

    def with_strike_or_spare?
      with_strike? || with_spare?
    end

    def with_strike?
      ordered_throws.first&.strike?
    end

    def with_spare?
      ordered_throws.second&.spare?
    end

    def throw_count
      @throw_count ||= throws.count
    end

    def update_game_state
      game.mark_completed if last_frame? && closed?
    end

    def update_game_score
      game.update_score
    end

    def calculate_play_score
      knocked_pins
    end

    def calculate_spare_score
      (knocked_pins + next_one_throw.knocked_pins) if next_one_throw
    end

    def calculate_strike_score
      if next_two_throws.size == 2
        (knocked_pins + next_two_throws.sum(&:knocked_pins))
      end
    end

    def next_one_throw
      @next_one_throw ||= next_throws.first
    end

    def next_two_throws
      @next_two_throws ||= next_throws.first(2)
    end

    def next_throws
      game.throws
      .where("throws.created_at > ?", throws.last.created_at)
      .order("throws.created_at ASC")
    end

    def game_should_be_open
      errors.add(:base, 'Game completed. No more frames can be played for this game.') unless game.open?
    end

    def frame_count_within_max_frames
      unless game.frames.count < Game::MAX_FRAMES
        errors.add(:base, "Max frames allowed is #{ Game::MAX_FRAMES }.")
      end
    end
end
