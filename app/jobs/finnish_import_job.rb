class FinnishImportJob < ApplicationJob
  queue_as :import

  def perform(user_id, as_sync: false)
    $import_pool.with do
      user = User.find(user_id)

      update_outre_mer_harbours

      ImportMailer.done(user).deliver_now unless as_sync
    end
  end

  private

  def update_outre_mer_harbours
    lat = 48
    lng = -6.95

    [
      "pointe-à-pitre",
      "fort-de-france",
      "dégrad des cannes",
      "port réunion"
    ].each do |name|
      Harbour.where("LOWER(name) = ?", name).update(latitude: lat, longitude: lng)

      lat -= 1
    end
  end
end
