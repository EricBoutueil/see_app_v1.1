class ImportJob < ApplicationJob
  queue_as :import

  def perform(user_id, rows, as_sync: false)
    # use a pool with of only 1 worker
    # Otherwise the splitted import could create simulteanously
    # the same data records, and we don't want that !
    $import_pool.with do
      importer = Importer.new(rows.map(&:symbolize_keys))
      importer.call
    rescue => ex
      user = User.find user_id
      ImportMailer.error(user, rows, ex).deliver_now

      raise if as_sync
    end
  end
end
