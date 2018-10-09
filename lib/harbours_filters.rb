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
      sum_volumes = 0

      all_harbours.each do |harbour|
        harbour.filtered_volume = compute_volume(harbour.movements)
        harbour.filtered_unit = compute_unit(harbour.movements)
        sum_volumes += harbour.filtered_volume
      end

      if sum_volumes > 0
        all_harbours.select { |h| h.filtered_volume > 0 }
      else
        all_harbours
      end

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

    # Total volume.
    # For each movement type code:
    # - either we use the "total" when it exist
    # - either we sum imp + exp

    total = 0
    movements.group_by(&:code).each_value do |mvmts|
      mvm_tot = mvmts.detect(&:tot?)

      total += if mvm_tot.present?
        mvm_tot.volume
      else
        mvmts.sum(&:volume)
      end
    end

    total
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
