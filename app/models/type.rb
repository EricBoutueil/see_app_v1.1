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
  def self.all_subfamilies1 #(params)
    # binding.pry

    # (params[:flow] == ["imp"] || params[:flow] == ["exp"])

    @subfamilies1 = []
      Type.all.each do |t|
        unless @subfamilies1.include?({code: t.code, label: t.label})
          # if t.code.to_s.length == 2
            @subfamilies1 << {code: t.code, label: t.label}
          # end
        end
      end
    return @subfamilies1
  end

end
