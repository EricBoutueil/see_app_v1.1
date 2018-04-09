class Movement < ApplicationRecord
  belongs_to :harbour
  belongs_to :type

  # delegate :code, :flow, :to => :type

  validates :year, presence: true, uniqueness: { scope: [:harbour, :type ],
    message: "already exists for harbour and flow" }
  validates :volume, presence: true, numericality: true

  def type_identification
    "#{self.type.code} #{self.type.flow}"
  end

  def self.all_years
    # binding.pry
    @years = []
      Movement.all.each do |m|
        unless @years.include?(m.year)
          @years << m.year
        end
      end
    return @years
  end

  ALL_YEARS = self.all_years

end
