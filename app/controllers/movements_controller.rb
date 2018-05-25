require "importer"

class MovementsController < ApplicationController
  before_action :ensure_admin!
  skip_after_action :verify_authorized, only: :import

  def import
    if request.post?
      if params[:file] == nil
        flash.now[:notice] = "Veuillez choisir un fichier non vide."
      else
        Thread.new {
          importer = Importer.new(params[:file])
          importer.call
        }

        redirect_to admin_movements_path, notice: "Base de données en train d'être mises à jour, ceci peut prendre plusieurs minutes !"
      end
    end
  end
end
