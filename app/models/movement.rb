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
      # puts "#{row[:name]}, a #{row[:appearance]} beer from #{row[:origin]}"
      # row[:id]    = row[:id].to_i          # Convert column to Integer
      # row[:cured] = row[:cured] == "true"  # Convert column to boolean
      # @totvol = self.movements.joins(:type).where(@mvts_criterias).where(types: @types_criterias).pluck(:volume).sum

      # @movement = Movement
      # .joins(:harbour, :type)
      # .where(harbours: {name: row[:name]}).where(types: {code: row[:code], flow: row[:flow]})
      # .first_or_create! do |mvt|
      #   binding.pry
      #   mvt.year = row[:year]
      #   mvt.volume = row[:volume]
      # end

      # # -> working but duplicating
      # Movement.create!(
      #   harbour: Harbour.find_by(name: row[:name]),
      #   type: Type.find_by(code: row[:code], flow: row[:flow]),
      #   year: row[:year],
      #   volume: row[:volume]
      #   )

      # # -> working but not updating
      # @movement = Movement
      # .joins(:harbour, :type)
      # .where(harbours: {name: row[:name].downcase})
      # .where(types: {code: row[:code].downcase, flow: row[:flow].downcase})
      # .first_or_create!(
      #   harbour: Harbour.find_by(name: row[:name].downcase),
      #   type: Type.find_by(code: row[:code].downcase, flow: row[:flow].downcase),
      #   year: row[:year].to_i,
      #   volume: row[:volume].to_i
      #   )

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
