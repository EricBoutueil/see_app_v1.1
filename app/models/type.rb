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
      Type.all.order(:code).each do |t|
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
    @subfamilies1 = []
    if (params[:fam])
      x = params[:fam].first[0]
      Type.all.order(:code).each do |t|
        unless @subfamilies1.include?({code: t.code, label: t.label})
          if t.code.to_s[0] == x
            if t.code.to_s.length == 2
              @subfamilies1 << {code: t.code, label: t.label}
            end
          end
        end
      end
      return @subfamilies1
    else
      # # filter not needed for user because of automatic ajax call:
      # Type.all.each do |t|
      #   unless @subfamilies1.include?({code: t.code, label: t.label})
      #     if t.code.to_s[0] == "a"
      #       if t.code.to_s.length == 2
      #         @subfamilies1 << {code: t.code, label: t.label}
      #       end
      #     end
      #   end
      # end
      return @subfamilies1
    end
  end

  # for Select2 subfamilies2
  def self.filtered_subfamilies2(params)
    @subfamilies2 = []
    if (params[:sub_one])
      x = params[:sub_one]
      Type.all.each do |t|
        unless @subfamilies2.include?({code: t.code, label: t.label})
          if x.include?(t.code.to_s[0, 2])
            if t.code.to_s.length == 3
              @subfamilies2 << {code: t.code, label: t.label}
            end
          end
        end
      end
      return @subfamilies2
    else
      return @subfamilies2
    end
  end

  # for Select2 subfamilies3
  def self.filtered_subfamilies3(params)
    @subfamilies3 = []
    if (params[:sub_two])
      x = params[:sub_two]
      Type.all.each do |t|
        unless @subfamilies3.include?({code: t.code, label: t.label})
          if x.include?(t.code.to_s[0, 3])
            if t.code.to_s.length == 4
              @subfamilies3 << {code: t.code, label: t.label}
            end
          end
        end
      end
      return @subfamilies3
    else
      return @subfamilies3
    end
  end

end
