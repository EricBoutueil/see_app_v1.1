class Harbour < ApplicationRecord
  has_many :movements, dependent: :nullify # custom TBD for archive -> history

  has_many :types, through: :movements

  validates :country, presence: true
  validates :name, presence: true, uniqueness: true
  validates :address, presence: true, uniqueness: true

  geocoded_by :full_address
  after_validation :geocode, if: :latitude_nil?

  attribute :filtered_volume
  attribute :filtered_unit

  def latitude_nil?
    self.latitude.nil?
  end

  def full_address
    "port #{name}, #{address}, #{country}"
  end
end

# NOTES:
# .pluck = .map in pur SQL
