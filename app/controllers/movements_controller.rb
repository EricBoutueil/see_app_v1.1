require "importer"

class MovementsController < ApplicationController
  before_action :ensure_admin!
  skip_after_action :verify_authorized, only: [:import, :import_light]

  def import
    if request.post?
      if params[:file] == nil
        flash.now[:notice] = "Veuillez choisir un fichier non vide."
      else
        Importer.enqueue_jobs(current_user, params[:file].path)

        redirect_to admin_dashboard_path, notice: "Base de données en train d'être mise à jour, vous recevrez un email lorsque ce sera terminé !"
      end
    end
  end

  def import_light
    if params[:file] == nil
      flash.now[:notice] = "Veuillez choisir un fichier non vide."
    else
      rows = Importer.rows_from_file(params[:file].path)

      begin
        ImportJob.perform_now(current_user.id, rows, as_sync: true)
        FinnishImportJob.perform_now(current_user.id, as_sync: true)

        redirect_to admin_dashboard_path, notice: "Mise à jour effectuée."
      rescue
        redirect_to admin_dashboard_path, alert: "Une erreur est survenue. Les détails vous ont été envoyés par email."
      end
    end
  end
end
