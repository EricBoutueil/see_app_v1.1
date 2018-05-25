class Importer
  attr_reader :file

  def initialize(file)
    @file = file
  end

  def call
    CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
      # updating if lat nil or creating harbours
      name = row[:name]&.downcase&.strip
      code = row[:code]&.downcase&.strip
      flow = row[:flow]&.downcase&.strip

      update_or_create_harbour(name, row)

      update_outre_mer("pointe-à-pitre", 48, -6.95)
      update_outre_mer("fort-de-france", 47, -6.95)
      update_outre_mer("dégrad des cannes", 46, -6.95)
      update_outre_mer("port réunion", 45, -6.95)

      update_or_create_type(code, flow, row)

      update_or_create_movement(name, code, flow, row)
    end
  end

  private

  def update_or_create_harbour(name, row)
    return if name.nil?

    scope = Harbour.where(name: name)

    if scope.where(latitude: nil).exists?
      scope.update(
          country: row[:country],
          address: row[:address].downcase,
        )
      return
    end

    if scope.where.not(latitude: nil).exists?
      # NOOP
      return
    end

    Harbour.create!(
      name: name,
      country: row[:country],
      address: row[:address].downcase,
    )
  end

  def update_or_create_type(code, flow, row)
    return if code.nil?

    # update of type without flow column
    if flow.nil?
      hande_type_without_flow(row)
      return
    end

    scope = Type.where(code: code, flow: flow)

    if scope.exists?
      scope.update(
        label: row[:label].downcase,
        unit: row[:unit].downcase,
        description: row[:description].downcase
      )

      return
    end

    Type.create!(
      code: code,
      flow: flow,
      label: row[:label].downcase,
      unit: row[:unit].downcase,
      description: row[:description].downcase
    )
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

  def hande_type_without_flow(row)
    scope = Type.where(code: code)

    if scope.exists?
      scope.update(
        label: row[:label]&.downcase,
        unit: row[:unit].downcase,
        description: row[:description]&.downcase
      )

      return
    end

    %w[imp exp].each do |flow|
      Type.create!(
        code: code,
        flow: flow,
        label: row[:label]&.downcase,
        unit: row[:unit].downcase,
        description: row[:description]&.downcase
      )
    end
  end
end
