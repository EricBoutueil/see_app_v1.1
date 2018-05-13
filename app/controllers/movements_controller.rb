class MovementsController < ApplicationController

  def index
    @movements = policy_scope(Movement)
  end

  def import
    @movements = policy_scope(Movement)
    Movement.import(params[:file])
    redirect_to movements_path, notice: "Base de donnée mise à jour avec succès !"
  end
end
