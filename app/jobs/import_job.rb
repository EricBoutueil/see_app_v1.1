class ImportJob < ApplicationJob
  queue_as :import

  def perform(user_id, rows)
    # use a pool with of only 1 worker
    # Otherwise the splitted import could create simulteanously
    # the same data records, and we don't want that !
    $import_pool.with do
      importer = Importer.new(rows.map(&:symbolize_keys))
      importer.call
    end
  end
end
