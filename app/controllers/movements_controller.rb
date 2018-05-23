class MovementsController < ApplicationController

  def index
    @movements = policy_scope(Movement)
  end

  def import
    @movements = policy_scope(Movement)

    if params[:file] == nil
      redirect_to movements_path, alert: "Veuillez choisir un fichier non vide."
    else
      Movement.import(params[:file])
      redirect_to movements_path, notice: "Base de donnée mise à jour avec succès !"
    end
  end
end
