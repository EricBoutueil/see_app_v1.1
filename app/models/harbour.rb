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

  # A) filtering harbours in geojson
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

  # B) filtering each selected harbour DB lines to calculate @totvol
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
    self.vol_filter_by_subfamily2(params) # -> (5b)
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

  def vol_filter_by_family(params) # (4) OK
    # binding.pry
    @types_criterias[:code] = if (params[:fam])
      if (params[:fam].length == 1)
        params[:fam]
      else
        "a"
      end
    else
      "a"
    end
  end

  def vol_filter_by_subfamily1(params) # (5a) -> criterias replace 4 in select2.js OK
    # binding.pry
    @types_criterias[:code] = if (params[:sub_one])
      # if (params[:sub_one].length == 2)
        params[:sub_one]
      # else
        # @types_criterias[:sub_one]
      # end
    else
      @types_criterias[:code]
    end
  end

  def vol_filter_by_subfamily2(params) # (5b) -> criterias add to 5a in select2.js TBF
    # binding.pry

    @types_criterias[:code] = if (params[:sub_two])
      # if (params[:sub_two].length == 3)
        params[:sub_two]
      # else
        # @types_criterias[:sub_two]
      # end
    else
      @types_criterias[:code]
    end

    # # @types_criterias[:code] = "a1"
    # @fam = @types_criterias[:code]
    # Type::filtered_subfamilies1.map do |t|
    #   if t[:code][0] == @fam
    #     @types_criterias[:code].to_a << ",#{t[:code]}"
    #   end
    # end
    # # binding.pry
  end



end

# NOTES:
# .pluck = .map in pur SQL
