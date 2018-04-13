class Type < ApplicationRecord
  has_many :movements, dependent: :nullify # custom TBD for archive

  enum flow: [:tot, :imp, :exp]

  validates :code, presence: true, uniqueness: { scope: :flow,
    message: "already exists for this flow" }
  validates :flow, presence: true

  # for ActiveAdmin dashboards
  def title
    "#{code} #{flow}"
  end

  # for Select2 flows
  def self.all_flows
    @flows = Type.flows.keys
  end

  # for Select2 families
  def self.all_families
    @families = []
      Type.all.each do |t|
        unless @families.include?({code: t.code, label: t.label})
          if t.code.to_s.length == 1
            @families << {code: t.code, label: t.label}
          end
        end
      end
    return @families
  end

  # for Select2 subfamilies1
  def self.filtered_subfamilies1(params) # before was: all_subfamilies1
    # binding.pry

    @subfamilies1 = []
    if (params[:code])
      x = params[:code].first[0]
      Type.all.each do |t|
        unless @subfamilies1.include?({code: t.code, label: t.label})
        # binding.pry
          if t.code.to_s[0] == x
            if t.code.to_s.length == 2
              @subfamilies1 << {code: t.code, label: t.label}
            end
          end
        end
      end
      return @subfamilies1
    else
      # Type.all.each do |t| # -> filter not needed for user because automatic ajax call
      #   unless @subfamilies1.include?({code: t.code, label: t.label})
      #     if t.code.to_s[0] == "a"
      #       if t.code.to_s.length == 2
      #         @subfamilies1 << {code: t.code, label: t.label}
      #       end
      #     end
      #   end
      # end
      # binding.pry
      @subfamilies1 = [{code: "see type.rb", label: "html view only"}]
      return @subfamilies1
    end
  end


  # def vol_filter_by_subfamily1(params) # (5a) -> criterias replace 4 in select2.js OK
  #   # binding.pry
  #   @types_criterias[:code] = if (params[:code])
  #     if (params[:code].length == 2)
  #       params[:code]
  #     else
  #       @types_criterias[:code]
  #     end
  #   else
  #     @types_criterias[:code]
  #   end
  # end


  # # filtering options for select2 thanks to params
  # def options_filter(params)
  #   @fam = @types_criterias[:code]
  #   Type::all_subfamilies1.map do |t|
  #     if t[:code][0] == @fam
  #       @types_criterias[:code].to_a << ",#{t[:code]}"
  #     end
  #   end
  #   binding.pry
  # end

# note ruby doc: a[2, 3] #=> "llo"

end
