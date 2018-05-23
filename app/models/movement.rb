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


      # updating if lat nil or creating harbours
      if row[:name] == nil # in case of types update only
      elsif  Harbour
      .where(name: row[:name].to_s.downcase)
      .where(latitude: nil)
      .exists?
        Harbour
        .where(name: row[:name].to_s.downcase)
        .update(
        country: row[:country],
        name: row[:name].to_s.downcase,
        address: row[:address].to_s.downcase
        )
      elsif Harbour
      .where(name: row[:name].to_s.downcase)
      .where.not(latitude: nil)
      .exists?
        puts 'ok'
      else
        Harbour.create!(
        country: row[:country],
        name: row[:name].to_s.downcase,
        address: row[:address].to_s.downcase
        )
      end

      if Harbour.where(name: "pointe-à-pitre").exists?
        Harbour.where(name: "pointe-à-pitre").update(
          latitude: 48,
          longitude: -6.95
          )
      end

      if Harbour.where(name: "fort-de-france").exists?
        Harbour.where(name: "fort-de-france").update(
          latitude: 47,
          longitude: -6.95
          )
      end

      if Harbour.where(name: "dégrad des cannes").exists?
        Harbour.where(name: "dégrad des cannes").update(
          latitude: 46,
          longitude: -6.95
          )
      end

      if Harbour.where(name: "port réunion").exists?
        Harbour.where(name: "port réunion").update(
          latitude: 45,
          longitude: -6.95
          )
      end

      # updating or creating types
      if row[:code] == nil # in case of harbours update only
      elsif row[:flow] == nil
        # update of type without flow column
        if Type
          .where(code: row[:code].to_s.downcase)
          .exists?
            Type
            .where(code: row[:code].to_s.downcase)
            .each do |type|
              type.update(
                label: row[:label].to_s.downcase,
                unit: row[:unit].to_s.downcase,
                description: row[:description].to_s.downcase
                )
            end
        else
          Type.create!(
            code: row[:code].to_s.downcase,
            flow: "imp",
            label: row[:label].to_s.downcase,
            unit: row[:unit].to_s.downcase,
            description: row[:description].to_s.downcase
            )
          Type.create!(
            code: row[:code].to_s.downcase,
            flow: "exp",
            label: row[:label].to_s.downcase,
            unit: row[:unit].to_s.downcase,
            description: row[:description].to_s.downcase
            )
        end
      elsif Type
      .where(code: row[:code].to_s.downcase, flow: row[:flow].to_s.downcase)
      .exists?
        Type
        .where(code: row[:code].to_s.downcase, flow: row[:flow].to_s.downcase)
        .update(
          label: row[:label].to_s.downcase,
          unit: row[:unit].to_s.downcase,
          description: row[:description].to_s.downcase
          )
      else
        Type.create!(
          code: row[:code].to_s.downcase,
          flow: row[:flow].to_s.downcase,
          label: row[:label].to_s.downcase,
          unit: row[:unit].to_s.downcase,
          description: row[:description].to_s.downcase
          )
      end

    # updating or creating movements (on existing harbours)
      if row[:year] == nil
      elsif Movement
      .joins(:harbour, :type)
      .where(harbours: {name: row[:name].to_s.downcase})
      .where(types: {code: row[:code].to_s.downcase, flow: row[:flow].to_s.downcase})
      .where(year: row[:year])
      .exists?
        Movement
        .joins(:harbour, :type)
        .where(harbours: {name: row[:name].to_s.downcase})
        .where(types: {code: row[:code].to_s.downcase, flow: row[:flow].to_s.downcase})
        .where(year: row[:year])
        .update(
          volume: row[:volume].to_i,
          terminal: row[:terminal].to_s.downcase,
          pol_pod: row[:pol_pod].to_s.downcase
          )
      else
        Movement.create!(
          harbour: Harbour.find_by(name: row[:name].to_s.downcase),
          type: Type.find_by(code: row[:code].to_s.downcase, flow: row[:flow].to_s.downcase),
          year: row[:year].to_i,
          volume: row[:volume].to_i,
          terminal: row[:terminal].to_s.downcase,
          pol_pod: row[:pol_pod].to_s.downcase
          )
      end
    end
  end

end
