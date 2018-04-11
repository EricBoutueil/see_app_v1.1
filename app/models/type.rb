class Type < ApplicationRecord
  has_many :movements, dependent: :nullify # custom TBD for archive

  enum flow: [:tot, :imp, :exp]

  validates :code, presence: true, uniqueness: { scope: :flow,
    message: "already exists for this flow" }
  validates :flow, presence: true

  # def type_identification
  #   "#{code} #{flow}"
  # end

  # for Select2 families
  def self.all_families
    @families = []
      Type.all.each do |t|
        unless @families.include?(t.code)
          if t.code.to_s.length == 1
            @families << t.code
          end
        end
      end
    return @families
  end

end
