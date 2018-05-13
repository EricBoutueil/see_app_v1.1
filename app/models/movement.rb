class Movement < ApplicationRecord
  require 'csv'

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
      self.all.each do |m|
        unless @years.include?(m.year)
          @years << m.year
        end
      end
    return @years
  end

  def self.max_year
    @max_year = self.all_years.max
  end

  def self.import(file)
    # csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }

    CSV.foreach(file.path, headers: true, header_converters: :symbol ) do |row|

    # updating or creating movements (on existing harbours)
      if Movement
      .joins(:harbour, :type)
      .where(harbours: {name: row[:name].downcase})
      .where(types: {code: row[:code].downcase, flow: row[:flow].downcase})
      .exists?
        Movement
        .joins(:harbour, :type)
        .where(harbours: {name: row[:name].downcase})
        .where(types: {code: row[:code].downcase, flow: row[:flow].downcase})
        .update(
          volume: row[:volume].to_i
          )
      else
        Movement.create!(
          harbour: Harbour.find_by(name: row[:name].downcase),
          type: Type.find_by(code: row[:code].downcase, flow: row[:flow].downcase),
          year: row[:year].to_i,
          volume: row[:volume].to_i
          )
      end

    end
  end

end
