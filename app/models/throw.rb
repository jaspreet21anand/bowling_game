class Throw < ApplicationRecord
  belongs_to :frame
  has_one :game, through: :frame

  validates :knocked_pins, presence: true
  validates :knocked_pins, numericality: { only_integer: true,
    greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validate :sum_of_knocked_pins_within_max_pins, :game_should_be_open, :frame_should_be_open

  enum knock_type: { play: 0, strike: 1, spare: 2 }

  before_create :set_knock_type

  after_save :update_frame_state, :calculate_frame_scores # order of callback is important here

  delegate :update_frame_state, to: :frame

  def self.add(pin_fall_count, game_id)
    ActiveRecord::Base.transaction do
      game = Game.find game_id
      current_frame = game.frames.last if game.frames.count == Game::MAX_FRAMES
      current_frame ||= game.frames.find_or_create_by(state: :open)
      current_frame.throws.create(knocked_pins: pin_fall_count)
    end
  end

  private

    def set_knock_type
      self.knock_type = if frame.last_frame?
        _previous_throw = (previous_throw&.strike? || previous_throw&.spare?) ? nil : previous_throw
        identify_knock_type(_previous_throw)
      else
        identify_knock_type(previous_throw)
      end
    end

    def identify_knock_type(previous_throw=nil)
      if knocked_pins == Frame::MAX_PINS
        :strike
      elsif previous_throw && (previous_throw.knocked_pins + self.knocked_pins) == Frame::MAX_PINS
        :spare
      else
        :play
      end
    end

    def previous_throw
      @previous_throw ||= frame.throws.last
    end

    def calculate_frame_scores
      # fetch previous 2 throws and find the unique frames_ids
      # then calculate scores for those frames
      game.throws.where.not(id: self.id).order("throws.created_at DESC").limit(2).each do |_throw|
        _throw.frame.calculate_and_update_frame_score
      end
    end

    def sum_of_knocked_pins_within_max_pins
      return if frame.additional_throws_awarded?
      unless self.knocked_pins <= (Frame::MAX_PINS - frame.knocked_pins)
        errors.add(:knocked_pins, 'Invalid knocked pins count. Max pin count exceeded.')
      end
    end

    def game_should_be_open
      errors.add(:base, 'Game completed. No more balls can be thrown for this game.') unless game.open?
    end

    def frame_should_be_open
      unless frame.open?
        errors.add(:frame, 'is closed. No more balls can be thrown for this frame.')
      end
    end
end
