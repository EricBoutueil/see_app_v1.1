class Harbour < ApplicationRecord
  has_many :movements, dependent: :nullify # custom TBD for archive -> history

  has_many :types, through: :movements

  validates :country, presence: true
  validates :name, presence: true, uniqueness: true
  validates :address, presence: true, uniqueness: true

  geocoded_by :full_address
  after_validation :geocode #:address_changed?


  YEAR_MAX = Movement.maximum("year") # to be updated with selharbours?

  def full_address
    "#{address}, #{country}"
  end

  # filter for harbours in geojson
  def self.filter_by_harbour(params, harbours)
    # binding.pry
    @selected_harbours = []
    if (params[:name])
      params[:name].each do |h|
        @selected_harbours << harbours.where(name: h).first
      end
    else
      @selected_harbours = harbours
    end
    return @selected_harbours
  end

  # filtering on each selected harbour DB lines to calculate @totvol
  # filters: (1)harb, (2)year, (3)flow, (4)fam, (5)subfam [+ (6)term, (7)pol_pod]
  def totvol_filter(params)
    # building 1 criterias hash by model, filter by filter
    @mvts_criterias = {}
    @types_criterias = {}
    # each feature == (1)
    self.vol_filter_by_year(params) # -> (2)
    self.vol_filter_by_flow(params) # -> (3)
    self.vol_filter_by_family(params) # -> (4)
    self.vol_filter_by_subfamily1(params) # -> (5a)
    # binding.pry
    @totvol = self.movements.joins(:type).where(@mvts_criterias).where(types: @types_criterias).pluck(:volume).sum
    # ex. -> where({year: ["2014", "2013"]}).where(types: {code: ["e"]})
end

  def vol_filter_by_year(params) # (2)
    @mvts_criterias[:year] = if (params[:year])
      params[:year]
    else
      YEAR_MAX
    end
  end

  def vol_filter_by_flow(params) #(3)
    # TBU if tot lines exist
    @types_criterias[:flow] = if (params[:flow] == ["imp"] || params[:flow] == ["exp"])
      params[:flow]
    elsif self.movements.joins(:type).where(types: {flow: ["tot"]}).exists?
          ["tot"]
    else
      ["imp", "exp"]
    end
  end

  def vol_filter_by_family(params) # (4)
    @types_criterias[:code] = if (params[:code])
      if (params[:code].length == 1)
        params[:code]
      else
        "a"
      end
    else
      "a"
    end
  end

  def vol_filter_by_subfamily1(params) # (5a)
    @types_criterias[:code] = if (params[:code])
      if (params[:code].length == 2)
        params[:code]
      end
    else
      # binding.pry
      # @types_criterias[:code] = "a"
      @fam = @types_criterias[:code]
      Type::all_subfamilies1.map do |t|
        if t[:code][0] == @fam
          @types_criterias[:code] << ",#{t[:code]}"
        end
      end
    end
  end

end

# NOTES:
# .pluck = .map in pur SQL
