class HarboursFilters
  attr_reader :harbour_scope
  attr_reader :movement_scope
  attr_reader :params

  delegate :name, :years, :flow, :code, to: :params

  def initialize(harbour_scope, movement_scope, params)
    @harbour_scope = harbour_scope
    @movement_scope = movement_scope.includes(:type)
    @params = params
  end

  def harbours
    @harbours ||= begin
      all_harbours = load_harbours

      all_harbours.each do |harbour|
        harbour.filtered_volume = compute_volume(harbour.movements)
        harbour.filtered_unit = compute_unit(harbour.movements)
      end

      all_harbours.select { |h| h.filtered_volume > 0 }
    end
  end

  private

  def load_harbours
    build_scopes

    harbours = harbour_scope

    ActiveRecord::Associations::Preloader.new.preload(harbours, :movements, movement_scope)

    harbours
  end

  def compute_volume(movements)

    return 0 if movements.empty?

    # imp or an exp volume
    return movements.select(&:"#{flow}?").sum(&:volume) if %w[imp exp].include?(flow)

    # we want the total. Either we have a movemnet for that, either this is the sum of movements
    movement_tot = movements.detect(&:tot?)
    return movement_tot.volume if movement_tot.present?

    movements.sum(&:volume)
  end

  def compute_unit(movements)
    movement = movements.detect { |m| code.include?(m.type.code) }
    return movement.type.unit if movement.present?

    "tonnes"
  end

  def build_scopes
    build_harbour_scope
    build_movement_scope
  end

  def build_harbour_scope
    @harbour_scope = harbour_scope.where(name: name) if name.present?
  end

  def build_movement_scope
    @movement_scope = movement_scope.where(year: years)

    types_criterias = {
      flow: (flow if %w[imp exp].include?(flow)),
      code: (code if code.present?),
    }.compact

    @movement_scope = movement_scope.where(types: types_criterias) if types_criterias.any?
  end
end
