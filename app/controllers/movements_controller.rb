require "importer"

class MovementsController < ApplicationController
  before_action :ensure_admin!
  skip_after_action :verify_authorized, only: :import

  def import
    if request.post?
      if params[:file] == nil
        flash.now[:notice] = "Veuillez choisir un fichier non vide."
      else
        Importer.dispatch(params[:file].path)

        redirect_to admin_dashboard_path, notice: "Base de données en train d'être mise à jour, vous recevrez un email lorsque ce sera terminé !"
      end
    end
  end
end
