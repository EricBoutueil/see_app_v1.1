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

  delegate :tot?, :imp?, :exp?, to: :type

  # for Select2 years
  def self.all_years
    @all_years ||= distinct("year").order(:year).pluck(:year)
  end

  def self.max_year
    @max_year ||= self.all_years.max
  end
end
