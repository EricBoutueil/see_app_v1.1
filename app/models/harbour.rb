class Harbour < ApplicationRecord
  has_many :movements, dependent: :nullify # custom TBD for archive

  has_many :types, through: :movements

  validates :country, presence: true
  validates :name, presence: true, uniqueness: true
  validates :address, presence: true, uniqueness: true

  geocoded_by :full_address
  after_validation :geocode #:address_changed?


  # @years = Movement.all_years

  # ALL_YEARS = self.all_years


  YEAR_MAX = Movement.maximum("year") # to be updated with selharbours?


  def full_address
    "#{address}, #{country}"
  end

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

  # above == functional

  def totvol_filter(params)
    # no sum, just filter selected lines
    # steps: if no filter -> (1) selected harbours, (2) harbours max year,
    # (3) A (and/or 4) all sub fam, (5) tot flux (or exp + imp) [, (6) term, (7) pol_pod]

    # -> (1) from feature
    # building a criterias hash step by step
    @mvts_criterias = {}
    @types_criterias = {}
    self.vol_filter_by_year(params) # -> (2)
    self.vol_filter_by_family(params) # -> (3) without (4)
    self.vol_filter_by_flow(params) # -> (5)
    @totvol = self.movements.includes(:type).where(@mvts_criterias, types: @types_criterias).pluck(:volume).sum
  end

  def vol_filter_by_year(params)
    # binding.pry
    @mvts_criterias[:year] = if (params[:year])
      params[:year]
    else
      YEAR_MAX
    end
  end

  def vol_filter_by_family(params)
    # (3) without (4)
    # == a or b, c, d, e => code.length == 1
    if (params[:code]) # note: can only have 1 familly code
      @types_criterias[:type][:code] = params[:code] # can include tot, imp, exp mvts
    else
      @types_criterias[:type] = {code: "a"}
    end
  end

  def vol_filter_by_flow(params)
    # (5)
    if (params[:flow])
      @types_criterias[:type][:flow] = if (params[:flow] == ( "imp" || "exp" )) # can be either tot, imp or exp mvt
        params[:flow] # can include only 1 flow
      else (params[:flow] == ( "tot"))
        "tot"
      end
    end
  end

    # # (4)
    # params[:code].each do |code|
    #   unless code.length == 1 #except a, b, c, d, e
    #     @mvts_subfam = @fams_mvt
    #   end

  # def self.tot_vol_max
  #   tot_vol_all = []
  #   @selected_harbours.each do |h|
  #     tot_vol_all << h.total_filter(params)
  #   end
  #   @tot_vol_max = tot_vol_all.max
  # end

end

# NOTES:
# .pluck = .map in pur SQL
