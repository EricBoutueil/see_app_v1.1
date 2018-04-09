class MovementsController < ApplicationController

  def index
    @movements = Movement.all
  end
end
