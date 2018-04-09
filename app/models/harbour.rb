class Harbour < ApplicationRecord
  has_many :movements, dependent: :nullify # custom TBD for archive

  has_many :types, through: :movements

  validates :country, presence: true
  validates :name, presence: true, uniqueness: true
  validates :address, presence: true, uniqueness: true

end
