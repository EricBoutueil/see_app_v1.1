require "importer"

class MovementsController < ApplicationController
  before_action :ensure_admin!

  def index
    @movements = policy_scope(Movement)
  end

  def import
    @movements = policy_scope(Movement)

    if params[:file] == nil
      redirect_to movements_path, alert: "Veuillez choisir un fichier non vide."
    else
      importer = Importer.new(params[:file])
      importer.call

      redirect_to movements_path, notice: "Base de donnée mise à jour avec succès !"
    end
  end
end
