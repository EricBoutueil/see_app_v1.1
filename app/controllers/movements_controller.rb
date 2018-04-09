class MovementsController < ApplicationController

  def index
    @movements = policy_scope(Movement)
  end
end
