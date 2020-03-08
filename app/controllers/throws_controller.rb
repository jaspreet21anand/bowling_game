class ThrowsController < ApplicationController

  before_action :load_game, only: :create

  def create
    current_frame = @game.frames.find_or_create_by(state: :open)
    throw = current_frame.throws.build(throw_params)
    if throw.save
      render json: { status: :success, message: 'Throw recorded successfully.',
        knocked_pins: throw.knocked_pins }
    else
      render json: { status: :error, message: throw.errors.full_messages.join(';') },
        status: :unprocessable_entity
    end
  end

  private
    def load_game
      @game = Game.find_by(id: params[:game_id])
      render json: { status: :error, message: 'Game not found.'},
        status: :not_found unless @game
    end

    def throw_params
      params.permit(:knocked_pins)
    end
end