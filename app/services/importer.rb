class Importer
  class << self
    def rows_per_job
      500
    end

    def enqueue_jobs(from_user, file)
      rows_from_file(file).in_groups_of(self.rows_per_job, false) do |rows|
        ImportJob.perform_later(from_user.id, rows)
      end

      FinnishImportJob.perform_later(from_user.id)
    end

    def rows_from_file(file)
      CSV.read(file, headers: true).map(&:to_h)
    end
  end


  attr_reader :rows

  def initialize(rows)
    @rows = rows
  end

  def call
    rows.each do |row|
      name = row[:name]&.downcase&.strip
      address = row[:address]&.downcase&.strip
      code = row[:code]&.downcase&.strip
      flow = row[:flow]&.downcase&.strip
      label = row[:label]&.downcase&.strip

      update_or_create_harbour(name, address, row)

      update_or_create_type(code, flow, label, row)

      update_or_create_movement(name, code, flow, row)
    end
  end

  private

  def update_or_create_harbour(name, address, row)
    return if name.nil? # if only updating types

    return if address.nil? # if only updating movements

    scope = Harbour.where(name: name)

    if scope.exists?
      scope.update(
          country: row[:country],
          address: address
        )
      return
    end

    # # cancelled to be able to udpate an address with CSV updload. Condition now on address not nil.
    # only update a harbour if latitude is nil in DB (because of Geocoding burden)
    # if scope.where(latitude: nil).exists?
      # scope.update(
      #     country: row[:country],
      #     address: address,
      #   )
      # return
    # end
    # if scope.where.not(latitude: nil).exists?
    #   # NOOP
    #   return
    # end

    Harbour.create!(
      name: name,
      country: row[:country],
      address: address,
    )
  end

  def update_or_create_type(code, flow, label, row)
    return if code.nil? # if only updating harbours

    return if label.nil? # if only updating movements

    # update of type without flow column
    if flow.nil?
      handle_type_without_flow(code, label, row)
      return
    end

    scope = Type.where(code: code, flow: flow)

    if scope.exists?
      scope.update(
        label: label,
        unit: row[:unit].downcase,
        description: row[:description].downcase
      )

      return
    end

    Type.create!(
      code: code,
      flow: flow,
      label: label,
      unit: row[:unit].downcase,
      description: row[:description].downcase
    )
  end

  def handle_type_without_flow(code, label, row)
    scope = Type.where(code: code)

    if scope.exists?
      scope.update(
        label: label,
        unit: row[:unit].downcase,
        description: row[:description]&.downcase
      )

      return
    end

    %w[imp exp].each do |flow|
      Type.create!(
        code: code,
        flow: flow,
        label: label,
        unit: row[:unit].downcase,
        description: row[:description]&.downcase
      )
    end
  end

  def update_or_create_movement(name, code, flow, row)
    return if row[:year].nil?

    harbour_id = Harbour.where(name: name).pluck(:id).first
    type_id = Type.where(code: code, flow: flow).pluck(:id).first

    scope = Movement.where(harbour_id: harbour_id, type_id: type_id, year: row[:year])

    if scope.exists?
      scope.update(
        volume: row[:volume].to_i,
        terminal: row[:terminal],
        pol_pod: row[:pol_pod],
      )

      return
    end

    Movement.create!(
      harbour_id: harbour_id,
      type_id: type_id,
      year: row[:year].to_i,
      volume: row[:volume].to_i,
      terminal: row[:terminal],
      pol_pod: row[:pol_pod],
    )
  end
end
