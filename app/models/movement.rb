class Movement < ApplicationRecord
  belongs_to :harbour
  belongs_to :type

  validates :year, presence: true, uniqueness: { scope: [:harbour, :type ],
    message: "already exists for harbour and flow" }
  validates :volume, presence: true, numericality: true

  # # previoulsy for ActiveAdmin dashboards
  # def type_title
  #   "#{self.type.code} #{self.type.flow}"
  # end

  # for Select2 years
  def self.all_years
    @years = []
      Movement.all.each do |m|
        unless @years.include?(m.year)
          @years << m.year
        end
      end
    return @years
  end

end
