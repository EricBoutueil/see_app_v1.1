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
    if (params[:fam])
      x = params[:fam].first[0]
      Type.all.each do |t|
        unless @subfamilies1.include?({code: t.code, label: t.label})
        # binding.pry
          if t.code.to_s[0] == x
            # binding.pry
            if t.code.to_s.length == 2
              @subfamilies1 << {code: t.code, label: t.label} # building OK
            end
          end
        end
      end
      return @subfamilies1
    else
      Type.all.each do |t| # -> filter not needed for user because automatic ajax call
        unless @subfamilies1.include?({code: t.code, label: t.label})
          if t.code.to_s[0] == "a"
            if t.code.to_s.length == 2
              @subfamilies1 << {code: t.code, label: t.label}
            end
          end
        end
      end
      # binding.pry
      # @subfamilies1 = [{code: "subfam1 see type.rb", label: "html view only"}] # for test only
      return @subfamilies1
    end
  end

  # for Select2 subfamilies2
  def self.filtered_subfamilies2(params)
    # binding.pry

    @subfamilies2 = []
    if (params[:sub_one])
      x = params[:sub_one].first[0, 2]
      Type.all.each do |t|
        unless @subfamilies2.include?({code: t.code, label: t.label})
        # binding.pry
          if t.code.to_s[0, 2] == x
            # binding.pry
            if t.code.to_s.length == 3
              @subfamilies2 << {code: t.code, label: t.label} # building OK
              # binding.pry
            end
          end
        end
      end
      return @subfamilies2
      # binding.pry
    else
      # Type.all.each do |t| # -> filter not needed for user because automatic ajax call
      #   unless @subfamilies2.include?({code: t.code, label: t.label})
      #     if t.code.to_s[0, 2] == "a1"
      #       if t.code.to_s.length == 3
      #         @subfamilies2 << {code: t.code, label: t.label}
      #       end
      #     end
      #   end
      # end
      # binding.pry
      @subfamilies2 = []
      return @subfamilies2
    end
  end

# note ruby doc: a[2, 3] #=> "llo"

end
