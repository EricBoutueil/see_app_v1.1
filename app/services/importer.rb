class Importer
  attr_reader :file

  def initialize(file)
    @file = file
  end

  def call
    CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
      # updating if lat nil or creating harbours
      name = row[:name]&.downcase&.strip
      address = row[:address]&.downcase&.strip
      code = row[:code]&.downcase&.strip
      flow = row[:flow]&.downcase&.strip
      label = row[:label]&.downcase&.strip

      update_or_create_harbour(name, address, row)

      update_outre_mer("pointe-à-pitre", 48, -6.95)
      update_outre_mer("fort-de-france", 47, -6.95)
      update_outre_mer("dégrad des cannes", 46, -6.95)
      update_outre_mer("port réunion", 45, -6.95)

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
          address: address,
          latitude: nil,
          longitude: nil,
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
      handle_type_without_flow(row)
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

  def handle_type_without_flow(row)
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


  def update_outre_mer(name, lat, lng)
    Harbour.where("LOWER(name) = ?", name).update(latitude: lat, longitude: lng)
  end

end
