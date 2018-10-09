FactoryBot.define do
  factory :harbour do
    country { "France" }
    name { "Le Rove" }
    address { name }
    latitude { 43.339 }
    longitude { 5.257 }
  end
end
