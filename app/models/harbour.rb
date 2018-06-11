class Harbour < ApplicationRecord
  has_many :movements, dependent: :nullify # custom TBD for archive -> history

  has_many :types, through: :movements

  validates :country, presence: true
  validates :name, presence: true, uniqueness: true
  validates :address, presence: true, uniqueness: true

  geocoded_by :full_address
  after_validation :geocode#, if: :latitude_nil? # now allowing to update when CSV address is not nil

  def latitude_nil?
    self.latitude.nil?
  end

  def full_address
    "port #{name}, #{address}, #{country}"
  end

  # STEP1: filtering harbours in geojson
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

  # STEP2: filtering each selected harbour DB lines to calculate @totvol
  # filters: (1)harb, (2)year, (3)flow, (4)fam, (5)subfam [+ (6)term, (7)pol_pod]
  def totvol_filter(params)
    # building 1 criterias hash by model, filter by filter
    @mvts_criterias = {}
    @types_criterias = {}
    # each feature == filter (1)
    self.vol_filter_by_year(params) # -> (2)
    self.vol_filter_by_flow(params) # -> (3)
    self.vol_filter_by_family(params) # -> (4)
    self.vol_filter_by_subfamily1(params) # -> (5a)
    self.vol_filter_by_subfamily2(params) # -> (5b)
    self.vol_filter_by_subfamily3(params) # -> (5c)
    # binding.pry
    @totvol = self.movements.joins(:type).where(@mvts_criterias).where(types: @types_criterias).pluck(:volume).sum
    # ex. -> where({year: ["2014", "2013"]}).where(types: {code: ["e"]})
  end

  def vol_filter_by_year(params) # (2)
    @mvts_criterias[:year] = if (params[:year])
      params[:year]
    else
      Movement::max_year
    end
  end

  def vol_filter_by_flow(params) #(3)
    @types_criterias[:flow] = if (params[:flow] == ["imp"] || params[:flow] == ["exp"])
      params[:flow]
    elsif self.movements.joins(:type).where(types: {flow: ["tot"]}).exists?
          ["tot"]
    else
      ["imp", "exp"]
    end
  end

  def vol_filter_by_family(params) # (4) OK
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

  def filtered_family_unit(params)
    @filtered_family_unit = if (params[:fam])
      if (params[:fam].length == 1)
        self.movements.joins(:type).where(types: {code: params[:fam]}).select('unit as unit_fam').first.unit_fam
      else
        "tonnes"
      end
    else
      "tonnes"
    end
  end

  def vol_filter_by_subfamily1(params) # (5a) -> criterias replace 4 in select2.js OK
    if (params[:sub_one])
      @types_criterias[:code] = params[:sub_one]
    end
  end

  def vol_filter_by_subfamily2(params) # (5b) -> criterias add to 5a in select2.js TBF
    if (params[:sub_two])
      sub_two_array = params[:sub_two]
      params[:sub_one].each do |pso|
        unless params[:sub_two].any? {|pst| pst.to_s[0, 2] == pso}
          sub_two_array << pso
        end
      end
      @types_criterias[:code] = sub_two_array
    end
  end

  def vol_filter_by_subfamily3(params) # (5c) -> criterias add to 5b in select2.js TBF
    if (params[:sub_three])
      sub_three_array = params[:sub_three]
      params[:sub_two].each do |pstw|
        unless params[:sub_three].any? {|pstr| pstr.to_s[0, 3] == pstw}
          sub_three_array << pstw
        end
      end
      @types_criterias[:code] = sub_three_array
    end
  end

end

# NOTES:
# .pluck = .map in pur SQL
