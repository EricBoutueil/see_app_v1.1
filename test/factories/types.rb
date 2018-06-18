FactoryBot.define do
  factory :type do
    code "b1"
    label "Some label"
    description ""
    flow "tot"
    unit "tonnes"

    trait :imp do
      flow "imp"
    end

    trait :exp do
      flow "exp"
    end
  end
end
