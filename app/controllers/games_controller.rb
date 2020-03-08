class GamesController < ApplicationController

  before_action :load_game, only: :show

  def create
    game = Game.new
    if game.save
      render json: { status: :success, message: 'New game started', game_id: game.id }
    else
      render json: { status: :error, message: game.errors.full_messages.join(';') },
        status: :unprocessable_entity
    end
  end

  def show
    render json: { status: :success, game: @game.
      as_json(only: [:score, :state], methods: :score_details) }
  end

  private
    def load_game
      unless @game = Game.find_by(id: params[:id])
        render json: { status: :error, message: 'Game not found' }, status: :not_found
      end
    end
end
